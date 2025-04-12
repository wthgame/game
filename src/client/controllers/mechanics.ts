import { Controller, OnInit, OnTick } from "@flamework/core";
import CullThrottle from "@rbxts/cullthrottle";
import { Entity } from "@rbxts/jecs";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { trace, warn } from "shared/log";

type Typechecker = (value: unknown) => LuaTuple<[boolean, Maybe<string>]>;

export interface Mechanic {
	type: "Mechanic";
	name: string;
	/// Whether this mechanic should "persist" running systems even when it is
	/// not visible.
	persistant: boolean;
	init(schedule: (fn: (dt: number) => void) => void): void;
}

export const Mechanic = ty
	.Struct(
		{ exhaustive: false },
		{
			type: ty.Just("Mechanic"),
			name: ty.String,
			persistant: ty.Boolean.IntoDefault(false),
			init: ty.Function,
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

@Controller()
export class MechanicController implements OnInit, OnTick {
	private mechanics!: Mechanic[];
	private mechanicSystems = new Map<Mechanic, Array<(dt: number) => void>>();
	private mechanicsNeedingToRunSystems = new Set<Mechanic>();
	private mechanicTags = new Map<string, MechanicTag>();
	private mechanicAttributes = new Set<MechanicAttribute>();
	private cull = new CullThrottle();

	onInit(): void {
		trace("Collecting Mechanics");
		this.mechanics = this.requireMechanics(MECHANICS_PARENT.getValue());
		trace("Finished");

		trace("Initializing Mechanics");
		this.initMechanics(this.mechanics);
		trace("Finished");
	}

	onTick(dt: number): void {
		for (const [, systems] of pairs(this.mechanicSystems)) {
			for (const system of systems) system(dt);
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

	private initMechanics(mechanics: Mechanic[]) {
		for (const mechanic of mechanics) {
			const scheduled: Array<(dt: number) => void> = [];
			function schedule(system: (dt: number) => void) {
				scheduled.push(system);
			}

			const [initSuccess, initValue] = pcall((s) => mechanic.init(s), schedule);

			if (initSuccess) {
				this.mechanicSystems.set(mechanic, scheduled);
			} else {
				warn(`Failed to initialize mechanic ${mechanic.name}: ${initValue}`);
			}
		}

		print(this.mechanicSystems);
	}

	// TODO: implement
	// TODO: collect all known mechanics and only run the attached systems
	// TODO: cull throttle
	loadFromParent(parent: Instance) {
		// debug.profilebegin("MechanicController.loadFromParent");
		trace("Loading mechanics from parent", parent.GetFullName());

		const trove = new Trove();

		// this is catastrophic
		for (const descendant of parent.GetDescendants()) {
			for (const [tag, { component, mechanic, check }] of pairs(this.mechanicTags)) {
				if (!descendant.HasTag(tag)) continue;
				this.mechanicsNeedingToRunSystems.add(mechanic);
			}
		}

		return trove;

		// debug.profileend();
	}
}
