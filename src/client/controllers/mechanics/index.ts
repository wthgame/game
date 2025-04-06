import { Controller, OnInit, OnStart } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import Object from "@rbxts/object-utils";
import { ReplicatedStorage, Workspace } from "@rbxts/services";
import Sift from "@rbxts/sift";
import { debug, info, trace, warn } from "shared/log";

export interface MechanicDescription<A extends Record<string, AttributeValue>, I extends Instance> {
	type: "MechanicDescription";
	name: string;
	attributes: { [K in keyof A]: (value: unknown) => value is A[K] };
	defaultAttributes: A;
	instanceCheck: (value: unknown) => value is I;
	mechanize(scope: MechanizeScope<A, I>): void | undefined | (() => void);
}

type AnyMechanicDescription = MechanicDescription<Record<string, AttributeValue>, Instance>;

export const MechanicDescription = ty
	.Struct(
		{ exhaustive: true },
		{
			type: ty.Just("MechanicDescription"),
			name: ty.String,
			attributes: ty.MapOf(ty.String, ty.Unknown),
			defaultAttributes: ty.MapOf(ty.String, ty.Unknown),
			instanceCheck: ty.Function,
			mechanize: ty.Function,
		},
	)
	.Nicknamed("MechanicDescription")
	.Retype<AnyMechanicDescription>();

export interface MechanizeScope<A extends Record<string, AttributeValue>, I extends Instance> {
	id: number;
	instance: I;
	mechanicsFolder: Instance;
	getAttribute<T extends keyof A>(attribute: T): A[T];
	insertTasks<Tasks extends unknown[]>(...tasks: Tasks): LuaTuple<Tasks>;
}

interface MechanicDescriptionModule {
	modulePath: string[];
	description: AnyMechanicDescription;
}

const MECHANICS_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

@Controller()
export class MechanicsController implements OnInit, OnStart {
	private modules!: Set<MechanicDescriptionModule>;

	onInit(): void {
		debug("Collecting MechanicDescriptions");
		this.modules = this.collectChildrenMechanicModules(MECHANICS_MODULES_PARENT.getValue(), []);
		debug("Finished");
	}

	onStart(): void {
		debug(
			"MechanicDescriptions registered:",
			Object.keys(this.modules)
				.map(({ modulePath }) => modulePath.join("."))
				.join(", "),
		);

		// this is so ass
		task.wait(5);

		print("game loaded");

		this.loadFromParent(Workspace.WaitForChild("Mechanics"));
	}

	private collectChildrenMechanicModules(parent: Instance, path: string[]): Set<MechanicDescriptionModule> {
		trace("Collecting MechanicDescriptions from", parent.GetFullName());
		const collectedModules = new Set<MechanicDescriptionModule>();

		for (const child of parent.GetChildren()) {
			if (child.IsA("ModuleScript")) {
				const modulePath = table.clone(path);
				modulePath.push(child.Name);

				const [requireSuccess, requireValue] = pcall(require, child);
				if (!requireSuccess) {
					warn(`Failed to load module ${child.GetFullName()}:`, requireValue as never);
				}

				const maybeDescription = MechanicDescription.Cast(requireValue);
				if (maybeDescription.some) {
					trace("Collected MechanicDescription from", child.GetFullName());
					collectedModules.add({ modulePath, description: maybeDescription.value });
					continue;
				}

				trace(
					`Ignoring module ${child.GetFullName()} because it did not match MechanicDescription;`,
					maybeDescription.reason ?? "(no reason provided)",
				);
			}

			const childPath = table.clone(path);
			childPath.push(child.Name);

			for (const m of this.collectChildrenMechanicModules(child, childPath)) collectedModules.add(m);
		}

		return collectedModules;
	}

	private loadFromParent(mechanicsFolder: Instance) {
		info("Loading mechanics from", mechanicsFolder.GetFullName());
		let id = 0;

		print(mechanicsFolder, "DESCENDANTS", mechanicsFolder.GetDescendants());
		for (const descendant of mechanicsFolder.GetDescendants()) {
			print(descendant);
			if (descendant.Name !== "Mechanic") continue;
			if (!classIs(descendant, "StringValue")) continue;

			trace(
				"Found Mechanic StringValue at",
				descendant.GetFullName(),
				"now checking for matching MechanicDescriptions",
			);

			const matchingMechanicDescriptions = new Set<AnyMechanicDescription>();
			for (const m of this.modules) {
				if (m.modulePath.join(".") === descendant.Value) {
					print(m, m.modulePath.join("."), descendant.Value);
					trace("Found matching MechanicDescription with path", m.modulePath);
					matchingMechanicDescriptions.add(m.description);
				}
			}

			const parent = descendant.Parent;
			if (!parent) {
				throw "Hanging Mechanic StringValue found, should be unreachable?";
			}

			if (matchingMechanicDescriptions.size() === 0) {
				warn(`No Mechanics found at ${descendant.Value} for ${parent.GetFullName()}`);
				continue;
			}

			trace("Now mechanizing", parent.GetFullName());
			const mechId = id++;

			for (const description of matchingMechanicDescriptions) {
				task.spawn(
					(description, mechanicsFolder, instance, id) => {
						trace("Mechanizing description", description.name);
						description.mechanize({
							mechanicsFolder,
							instance,
							id,

							getAttribute(attribute) {
								const instanceAttributeNow = instance.GetAttribute(attribute) as never;
								const defaultAttribute = description.defaultAttributes[attribute];
								return instanceAttributeNow || defaultAttribute;
							},

							insertTasks() {
								throw "not yet implemented";
							},
						});
					},
					description,
					mechanicsFolder,
					parent,
					mechId,
				);
			}
		}
	}
}
