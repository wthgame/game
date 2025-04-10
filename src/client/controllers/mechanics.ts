import { Controller, OnInit, OnStart, OnTick } from "@flamework/core";
import CullThrottle from "@rbxts/cullthrottle";
import { Entity, Name, World } from "@rbxts/jecs";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage } from "@rbxts/services";
import { world } from "shared/ecs";
import { trace } from "shared/log";

type Typechecker = (value: unknown) => LuaTuple<[boolean, Maybe<string>]>;
type InstanceAttributes = Record<string, AttributeValue>;

export interface Mechanic {
	type: "Mechanic";
	name: string;
	attach: (wth: WelcomeToHell) => void;
}

export const Mechanic = ty
	.Struct(
		{ exhaustive: true },
		{
			type: ty.Just("Mechanic"),
			name: ty.String,
			attach: ty.Function,
		},
	)
	.Nicknamed("Mechanic")
	.Retype<Mechanic>();

export interface MechanicComponentInner {
	attributes: InstanceAttributes;
	instance: Instance;
}

export type MechanicComponent = Entity<MechanicComponentInner>;

type MechanicComponentPrivate = {
	component: MechanicComponent;
	tag: string;
	attributeChecks: Map<string, Typechecker>;
	defaultAttributes: InstanceAttributes;
	instanceCheck: Typechecker;
};

export type CreateMechanicComponentProps = {
	tag: string;
	attributeChecks: Map<string, Typechecker>;
	defaultAttributes: InstanceAttributes;
	instanceCheck: Typechecker;
};

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

export const CreateMechanicComponentProps = ty
	.Struct(
		{ exhaustive: true },
		{
			tag: ty.String,
			attributeChecks: ty.MapOf(ty.String, ty.Function),
			defaultAttributes: ty.MapOf(ty.String, AttributeValue),
			instanceCheck: ty.Function,
		},
	)
	.Nicknamed("CreateMechanicComponentProps")
	.Retype<CreateMechanicComponentProps>();

export interface WelcomeToHell {
	world: World;
	createMechanicComponent: (props: CreateMechanicComponentProps) => MechanicComponent;
	pushSystems: (...systems: Array<() => void>) => void;
}

const MECHANICS_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

@Controller()
export class MechanicController implements OnInit, OnStart, OnTick {
	private mechanics!: Mechanic[];
	private mechanicSystems = new Map<Mechanic, Array<() => void>>();
	private mechanicsNeedingToRunSystems = new Set<Mechanic>();
	private mechanicComponents = new Set<MechanicComponentPrivate>();
	private mechanicInstances = new CullThrottle();

	onInit(): void {
		debug.profilebegin("Collecting Mechanics");
		trace("Collecting Mechanics");
		this.mechanics = this.requireMechanics(MECHANICS_PARENT.getValue());
		trace("Finished");
		debug.profileend();

		debug.profilebegin("Attaching Mechanics");
		trace("Attaching Mechanics");
		this.attachMechanics(this.mechanics);
		trace("Finished");
		debug.profileend();
	}

	onStart(): void {
		print(this);
	}

	onTick(dt: number): void {
		for (const [, systems] of pairs(this.mechanicSystems)) for (const s of systems) s();
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
		for (const mech of mechanics) {
			const mechanicSystems: Array<() => void> = [];

			const wth = table.freeze<WelcomeToHell>({
				world,

				createMechanicComponent: (props) => this.createMechanicComponent(props),

				pushSystems: (...systems) => {
					for (const s of systems) mechanicSystems.push(s);
				},
			});

			const [attachSuccess] = pcall(mech.attach, wth);

			this.mechanicSystems.set(mech, mechanicSystems);
		}
	}

	// TODO: implement
	// TODO: collect all known mechanics and only run the attached systems
	// TODO: cull throttle
	private loadFromParent(parent: Instance) {}

	private createMechanicComponent(props: unknown): MechanicComponent {
		const { tag, attributeChecks, defaultAttributes, instanceCheck } =
			CreateMechanicComponentProps.CastOrError(props);

		const component = world.component<MechanicComponentInner>();
		world.set(component, Name, tag);

		this.mechanicComponents.add({
			component,
			tag,
			attributeChecks,
			defaultAttributes,
			instanceCheck,
		});

		return component;
	}
}
