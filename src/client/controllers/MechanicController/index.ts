import { Controller, OnInit } from "@flamework/core";
import { Entity, Name } from "@rbxts/jecs";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage, RunService } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { world } from "shared/ecs";
import { panic } from "shared/flamework";
import { trace, warn } from "shared/log";

export interface Mechanic {
	type: "Mechanic";
	name: string;
	persistent: boolean;
	init: (self: Mechanic, wth: WTH) => void;
}

const Mechanic = ty
	.Struct(
		{ exhaustive: false },
		{
			type: ty.Just("Mechanic"),
			name: ty.String,
			persistent: ty.Boolean.IntoDefault(false),
			init: ty.Function,
		},
	)
	.Nicknamed("Mechanic")
	.Retype<Mechanic>();

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
	.Retype<AttributeValue>();

type InstanceAttributes = Map<string, AttributeValue>;
const InstanceAttributes = ty.MapOf(ty.String, AttributeValue);

interface MechanicTag<T extends Instance> {
	tag: string;
	check: t.check<T>;
	component: Entity<T>;
	mechanic: Mechanic;
}

const InstanceCheck = ty.Function.IntoDefault(t.Instance).Nicknamed("t.check<Instance>").Retype<t.check<Instance>>();

const MECHANICS_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

export class WTH {
	static world = world;

	constructor(
		private mechanic: Mechanic,
		private tags: Map<string, MechanicTag<Instance>>,
		private systems: Array<(dt: number, trove: Trove) => void>,
	) {}

	useTag(tag: string): Entity<Instance>;
	useTag<T extends Instance>(tag: string, optCheck: t.check<T>): Entity<T>;
	useTag<T extends Instance>(tag: string, optCheck?: t.check<T>): Entity<T> {
		ty.String.CastOrError(tag);
		const check = InstanceCheck.CastOrError(optCheck);

		const component = world.component<T>();
		world.set(component, Name, tag);

		this.tags.set(tag, {
			tag,
			check,
			component,
			mechanic: this.mechanic,
		});

		return component;
	}

	useAttribute<I extends Instance, T extends AttributeValue>(
		attributeName: string,
		tag: Entity<I>,
		check: t.check<T>,
		defaultValue: T,
	): Entity<T> {
		ty.String.CastOrError(attributeName);
		ty.Function.CastOrError(check);
		AttributeValue.CastOrError(defaultValue);

		const component = world.component<T>();
		world.set(component, Name, attributeName);

		const queryTag = world.query(tag).cached();

		this.systems.push(() => {
			for (const [entity, instance] of queryTag) {
				const realValue = instance.GetAttribute(attributeName);
				world.set(entity, component, realValue !== undefined && check(realValue) ? realValue : defaultValue);
			}
		});

		return component;
	}

	schedule(...systems: Array<(dt: number, trove: Trove) => void>) {
		// system systems systems system im going to go insane
		for (const system of systems) this.systems.push(system);
	}
}

@Controller()
export class MechanicController implements OnInit {
	private mechanicSystems = new Map<Mechanic, Array<(dt: number, trove: Trove) => void>>();
	private mechanicTags = new Map<string, MechanicTag<Instance>>();
	private mechanics = new Set<Mechanic>();

	async onInit() {
		const initPromises: Promise<void>[] = [];
		for (const mod of MECHANICS_PARENT.getValue().GetDescendants()) {
			initPromises.push(this.tryInitModule(mod));
		}
		await Promise.all(initPromises);
	}

	async tryInitModule(mod: Instance) {
		if (mod.IsA("ModuleScript")) {
			const [requireSuccess, required] = pcall(require, mod);
			if (requireSuccess) {
				if (Mechanic.Matches(required)) this.initMechanic(required as Mechanic);
			} else {
				warn(`Failed to require ${mod.GetFullName()}: ${required}`);
			}
		}
	}

	initMechanic(mechanic: Mechanic) {
		trace(`Initializing mechanic ${mechanic.name}`);
		const systems = new Array<(dt: number, trove: Trove) => void>();
		const wth = new WTH(mechanic, this.mechanicTags, systems);

		const [initSuccess, initError] = pcall(mechanic.init, mechanic, wth);

		if (initSuccess) {
			this.mechanicSystems.set(mechanic, systems);
		} else {
			panic(`Failed to initialize ${mechanic.name}: ${initError}`);
		}
	}

	// TODO: Impl cullthrottle
	// TODO: track new tags/removed tags
	async loadMechanicsFromParent(trove: Trove, parent: Instance) {
		trace(`Loading mechanics from parent ${parent.GetFullName()}`);
		const mechanicsUsed = new Set<Mechanic>();

		async function tryTrackTaggedInstance<T extends Instance>(
			instance: Instance,
			{ check, component, mechanic }: MechanicTag<T>,
		) {
			if (check(instance)) {
				print("adding instance", instance);
				const entity = world.entity();
				world.set(entity, component, instance);
				mechanicsUsed.add(mechanic);

				trove.add(
					instance.Destroying.Once(() => {
						world.delete(entity);
					}),
				);
			}
		}

		trace("Tracking tags");

		const trackPromises = new Array<Promise<void>>();
		for (const descendant of parent.GetDescendants()) {
			trace(`Checking ${descendant.GetFullName()}`);
			for (const [tag, component] of pairs(this.mechanicTags)) {
				if (descendant.HasTag(tag)) {
					trackPromises.push(tryTrackTaggedInstance(descendant, component));
				}
			}
		}

		await Promise.all(trackPromises);

		trace("Finished tracking tags");

		trace("Running systems");

		trove.add(
			RunService.PostSimulation.Connect((dt) => {
				for (const mechanic of mechanicsUsed) {
					print("mechanic", mechanic);
					for (const system of this.mechanicSystems.get(mechanic)!) {
						system(dt, trove);
					}
				}
			}),
		);
	}
}
