import { Controller, OnInit, OnStart, OnTick } from "@flamework/core";
import CullThrottle from "@rbxts/cullthrottle";
import { Entity, Name, OnAdd, OnRemove, World } from "@rbxts/jecs";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage, Workspace } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { world } from "shared/ecs";
import { panic } from "shared/flamework";
import { debug, err, info, trace, warn } from "shared/log";

type Typechecker = (value: unknown) => LuaTuple<[boolean, Maybe<string>]>;

export interface Mechanic {
	type: "Mechanic";
	name: string;
	/// Used for attaching to Welcome To Hell.
	attach: (wth: WthApi) => void;
	/// Whether this mechanic should "persist" running systems even when it is
	/// not visible.
	persistant: boolean;
}

export const Mechanic = ty
	.Struct(
		{ exhaustive: true },
		{
			type: ty.Just("Mechanic"),
			name: ty.String,
			attach: ty.Function,
			persistant: ty.Boolean.IntoDefault(false),
		},
	)
	.Nicknamed("Mechanic")
	.Retype<Mechanic>();

export interface MechanicTag {
	component: Entity<Instance>;
	mechanic: Mechanic;
	check: Typechecker;
}

export interface MechanicAttribute {
	component: Entity<InstanceAttributes>;
	tag: Entity<Instance>;
	mechanic: Mechanic;
	checks: Map<string, Typechecker>;
	defaults: Map<string, AttributeValue>;
}

export interface WthApi {
	world: World;
	createMechanicTag: (tag: string, check: Typechecker) => Entity<Instance>;
	createMechanicAttributes: (
		tag: Entity<Instance>,
		check: Map<string, Typechecker>,
		defaults: InstanceAttributes,
	) => Entity<InstanceAttributes>;
	pushSystems: (...systems: Array<() => void>) => void;

	logTrace: (...args: defined[]) => void;
	logDebug: (...args: defined[]) => void;
	logInfo: (...args: defined[]) => void;
	logWarn: (...args: defined[]) => void;
	logError: (...args: defined[]) => void;
}

export interface MechanicComponentInner {
	attributes: InstanceAttributes;
	instance: Instance;
}

export const AttributeValue = ty.String.Or(ty.Boolean)
	.Or(ty.Number)
	.Or(ty.Typeof("UDim").Retype<UDim>())
	.Or(ty.Typeof("UDim2").Retype<UDim2>())
	.Or(ty.Typeof("BrickColor").Retype<BrickColor>())
	.Or(ty.Typeof("Color3").Retype<Color3>())
	.Or(ty.Typeof("Vector2").Retype<Vector2>())
	.Or(ty.Typeof("Vector3").Retype<Vector3>())
	.Or(ty.Typeof("EnumItem").Retype<EnumItem>())
	.Or(ty.Typeof("NumberSequence").Retype<NumberSequence>())
	.Or(ty.Typeof("ColorSequence").Retype<ColorSequence>())
	.Or(ty.Typeof("NumberRange").Retype<NumberRange>())
	.Or(ty.Typeof("Rect").Retype<Rect>())
	.Or(ty.Typeof("Font").Retype<Font>())
	.Or(ty.Typeof("CFrame").Retype<CFrame>())
	.Nicknamed("AttributeValue")
	.Retype<AttributeValue>();

type InstanceAttributes = Map<string, AttributeValue>;
const InstanceAttributes = ty.MapOf(ty.String, AttributeValue);

const TypecheckerStruct = ty.MapOf(ty.String, ty.Function);

const MECHANICS_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));
const TEMPORARY_MECHANICS_TEST_FOLDER = new Lazy(() => Workspace.WaitForChild("Mechanics"));

@Controller()
export class MechanicController implements OnInit, OnStart, OnTick {
	private mechanics!: Mechanic[];
	private mechanicSystems = new Map<Mechanic, Array<() => void>>();
	private mechanicsNeedingToRunSystems = new Set<Mechanic>();
	private mechanicTags = new Map<string, MechanicTag>();
	private mechanicAttributes = new Set<MechanicAttribute>();
	private cull = new CullThrottle();

	onInit(): void {
		trace("Collecting Mechanics");
		this.mechanics = this.requireMechanics(MECHANICS_PARENT.getValue());
		trace("Finished");

		trace("Attaching Mechanics");
		this.attachMechanics(this.mechanics);
		trace("Finished");
	}

	onStart(): void {
		print(this);
		this.loadFromParent(TEMPORARY_MECHANICS_TEST_FOLDER.getValue());
	}

	onTick(): void {
		for (const mechanic of this.mechanicsNeedingToRunSystems) {
			for (const system of this.mechanicSystems.get(mechanic)!) {
				system();
			}
		}
	}

	private requireMechanics(parent: Instance): Mechanic[] {
		trace("Collecting Mechanics from", parent.GetFullName());

		const collectedMechanics: Mechanic[] = [];

		for (const descendant of parent.GetDescendants()) {
			if (!classIs(descendant, "ModuleScript")) continue;

			const [requireSuccess, requireValue] = pcall(require, descendant);
			if (!requireSuccess) {
				warn(`Failed to load module ${descendant.GetFullName()}:`, requireValue as never);
			}

			const maybeMechanic = Mechanic.Cast(requireValue);
			if (maybeMechanic.some) {
				const mechanic = maybeMechanic.value;
				trace("Collected Mechanic from", descendant.GetFullName(), "named", mechanic.name);
				collectedMechanics.push(mechanic);
				continue;
			}

			trace(
				`Ignoring module ${descendant.GetFullName()} because it did not match Mechanic;`,
				maybeMechanic.reason ?? "(no reason provided)",
			);
		}

		return collectedMechanics;
	}

	private attachMechanics(mechanics: Mechanic[]) {
		for (const mechanic of mechanics) {
			const mechanicSystems: Array<() => void> = [];

			const wth = table.freeze<WthApi>({
				world,

				createMechanicTag: (tag: string, check: Typechecker = t.Instance as never) => {
					ty.String.CastOrError(tag);
					ty.Function.CastOrError(check);

					if (this.mechanicTags.has(tag)) panic(`Duplicate tag ${tag}`);
					const component = world.component<Instance>();
					world.set(component, Name, tag);
					this.mechanicTags.set(tag, { component, mechanic, check });
					return component;
				},

				createMechanicAttributes: (
					tag: Entity<Instance>,
					checks: Map<string, Typechecker>,
					defaults: Map<string, AttributeValue>,
				) => {
					ty.Number.CastOrError(tag);
					TypecheckerStruct.CastOrError(checks);
					InstanceAttributes.CastOrError(defaults);

					const component = world.component<Map<string, AttributeValue>>();

					const attributeChangedConnections = new Map<Instance, RBXScriptConnection>();

					// Probably could do this as a system but im lazy :)
					world.set(tag, OnAdd, (e) => {
						const instance = world.get(e, tag);
						if (!instance) return;

						const instanceAttributes = instance.GetAttributes();
						const reconciledAttributes = new Map<string, AttributeValue>();

						for (const [key, value] of pairs(defaults)) {
							const instanceValue = instanceAttributes.get(key);
							if (instanceValue === undefined) {
								reconciledAttributes.set(key, value);
								continue;
							}

							const check = checks.get(key)!;
							const [matchesType, reason] = check(instanceValue);

							if (matchesType) {
								reconciledAttributes.set(key, instanceValue!);
							} else {
								warn(
									`Unexpected attribute type ${key} for mechanic tag ${world.get(tag, Name)}; ${reason}`,
								);

								reconciledAttributes.set(key, value);
							}
						}

						world.set(e, component, reconciledAttributes);

						attributeChangedConnections.set(
							instance,
							instance.AttributeChanged.Connect((attributeName) => {
								const existingAttributes = world.get(e, component);
								if (!existingAttributes) return;

								const attributes = table.clone(existingAttributes);

								const check = checks.get(attributeName);
								if (!check) return;

								const instanceValue = instance.GetAttribute(attributeName);

								const [matchesType, reason] = check(instanceValue);

								if (matchesType) {
									attributes.set(attributeName, instanceValue!);
									world.set(e, component, attributes);
								} else {
									warn(
										`Unexpected attribute type ${attributeName} for mechanic tag ${world.get(tag, Name)}; ${reason}`,
									);
								}
							}),
						);
					});

					world.set(tag, OnRemove, (e) => {
						const instance = world.get(e, tag);
						if (!instance) return;

						const connection = attributeChangedConnections.get(instance);
						if (connection) connection.Disconnect();

						world.remove(e, component);
					});

					this.mechanicAttributes.add({
						component,
						tag,
						mechanic,
						checks,
						defaults,
					});

					return component;
				},

				pushSystems: (...systems) => {
					for (const s of systems) mechanicSystems.push(s);
				},

				logTrace: (...args) => {
					trace(`Mechanic: ${mechanic.name} -`, ...args);
				},

				logDebug: (...args) => {
					debug(`Mechanic:${mechanic.name} -`, ...args);
				},

				logInfo: (...args) => {
					info(`Mechanic:${mechanic.name} -`, ...args);
				},

				logWarn: (...args) => {
					warn(`Mechanic:${mechanic.name} -`, ...args);
				},

				logError: (...args) => {
					err(`Mechanic:${mechanic.name} -`, ...args);
				},
			});

			const [attachSuccess, attachError] = pcall(mechanic.attach, wth);
			if (attachSuccess) {
				this.mechanicSystems.set(mechanic, mechanicSystems);
			} else {
				// warn(`Mechanic ${mechanic.name} errored while attaching, it will be ignored; ${attachError}`);
				panic(`Mechanic ${mechanic.name} errored while attaching; ${attachError}`);
				// mechanics.remove(mechanics.indexOf(mechanic));
				// this.mechanicSystems.clear();
				// this.mechanicComponents = new Set(
				// 	Object.keys(this.mechanicComponents).filter(({ mechanic }) => mechanic !== mech),
				// );
			}
		}
	}

	// TODO: implement
	// TODO: collect all known mechanics and only run the attached systems
	// TODO: cull throttle
	private loadFromParent(parent: Instance) {
		// debug.profilebegin("MechanicController.loadFromParent");
		debug("Loading mechanics from parent", parent.GetFullName());

		const trove = new Trove();

		// this is catastrophic
		for (const descendant of parent.GetDescendants()) {
			for (const [tag, { component, mechanic, check }] of pairs(this.mechanicTags)) {
				if (!descendant.HasTag(tag)) continue;

				const [matchesInstance, reason] = check(descendant);
				if (!matchesInstance) {
					warn(`Unexpected instance for mechanic tag ${tag}; ${reason}`);
					continue;
				}

				const entity = world.entity();
				world.set(entity, Name, descendant.Name);
				world.set(entity, component, descendant);

				this.mechanicsNeedingToRunSystems.add(mechanic);
			}
		}

		return trove;

		// debug.profileend();
	}
}
