import { Controller, OnInit, OnStart } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { panic } from "shared/flamework";
import { err, info, trace, warn } from "shared/log";

export interface Mechanic<A extends Record<string, AttributeValue>, I extends Instance> {
	type: "Mechanic";
	name: string;
	attributes: { [K in keyof A]: (value: unknown) => value is A[K] };
	defaultAttributes: A;
	instanceCheck: (value: unknown) => value is I;
	mechanize(scope: MechanizeScope<A, I>): void | undefined | (() => void);
}

type AnyMechanic = Mechanic<Record<string, AttributeValue>, Instance>;

export const Mechanic = ty
	.Struct(
		{ exhaustive: true },
		{
			type: ty.Just("Mechanic"),
			name: ty.String,
			attributes: ty.MapOf(ty.String, ty.Unknown),
			defaultAttributes: ty.MapOf(ty.String, ty.Unknown),
			instanceCheck: ty.Function,
			mechanize: ty.Function,
		},
	)
	.Nicknamed("Mechanic")
	.Retype<AnyMechanic>();

export interface MechanizeScope<A extends Record<string, AttributeValue>, I extends Instance> {
	id: number;
	instance: I;
	mechanicsFolder: Instance;
	getAttribute: <T extends keyof A>(attribute: T) => A[T];
	getAllAttributes: () => A;
	trove: Trove;

	logTrace: (...args: defined[]) => void;
	logDebug: (...args: defined[]) => void;
	logInfo: (...args: defined[]) => void;
	logWarn: (...args: defined[]) => void;
	logError: (...args: defined[]) => void;
}

type Tag = string;

const MECHANIC_TAG_PREFIX = "Mechanic:";
const MECHANICS_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

@Controller()
export class MechanicsController implements OnInit, OnStart {
	private modules!: Map<Tag, AnyMechanic>;

	onInit(): void {
		trace("Collecting Mechanics");
		this.modules = this.collectChildrenMechanicModules(MECHANICS_MODULES_PARENT.getValue());
		trace("Finished");
	}

	onStart(): void {
		print(this.modules);

		this.loadFromParent(Workspace.WaitForChild("Mechanics"));
	}

	private collectChildrenMechanicModules(parent: Instance): Map<Tag, AnyMechanic> {
		trace("Collecting Mechanics from", parent.GetFullName());
		const collectedModules = new Map<Tag, AnyMechanic>();

		for (const child of parent.GetChildren()) {
			if (child.IsA("ModuleScript")) {
				const [requireSuccess, requireValue] = pcall(require, child);
				if (!requireSuccess) {
					warn(`Failed to load module ${child.GetFullName()}:`, requireValue as never);
				}

				const maybeDescription = Mechanic.Cast(requireValue);
				if (maybeDescription.some) {
					trace("Collected Mechanic from", child.GetFullName());
					const description = maybeDescription.value;

					const tag = MECHANIC_TAG_PREFIX + description.name;
					trace("Collected with tag", tag);

					if (collectedModules.has(tag)) panic(`Duplicate Mechanic found with name: ${description.name}`);

					collectedModules.set(tag, description);
					continue;
				}

				trace(
					`Ignoring module ${child.GetFullName()} because it did not match Mechanic;`,
					maybeDescription.reason ?? "(no reason provided)",
				);
			}

			for (const [tag, mod] of pairs(this.collectChildrenMechanicModules(child))) collectedModules.set(tag, mod);
		}

		return collectedModules;
	}

	private loadFromParent(mechanicsFolder: Instance) {
		info("Loading mechanics from", mechanicsFolder.GetFullName());
		let id = 0;

		const trove = new Trove();

		for (const descendant of mechanicsFolder.GetDescendants()) {
			const mechanicsToLoad = new Array<AnyMechanic>();
			for (const tag of descendant.GetTags()) {
				const mechanic = this.modules.get(tag);
				if (mechanic) mechanicsToLoad.push(mechanic);
			}

			if (mechanicsToLoad.size() === 0) {
				trace(`No Mechanics found for ${descendant.GetFullName()}`);
				continue;
			}

			trace("Now mechanizing", descendant.GetFullName());
			const mechId = id++;

			for (const description of mechanicsToLoad) {
				const mechanicTrove = trove.extend();

				task.spawn(
					(description, mechanicsFolder, instance, id) => {
						trace("Mechanizing description", description.name);
						debug.setmemorycategory(description.name);

						description.mechanize(
							table.freeze({
								mechanicsFolder,
								instance,
								id,

								getAttribute: (attribute: string): AttributeValue => {
									const instanceAttributeNow = instance.GetAttribute(attribute) as never;
									const defaultAttribute = description.defaultAttributes[attribute];
									return instanceAttributeNow || defaultAttribute;
								},

								getAllAttributes: () => {
									const instanceAttributes = instance.GetAttributes();
									const reconciledAttributes = new Map();

									for (const [k, v] of pairs(description.defaultAttributes)) {
										reconciledAttributes.set(k, instanceAttributes.get(k) || v);
									}

									return reconciledAttributes as never;
								},

								trove,

								logTrace: (...args) => {
									trace(`Mechanic:${description.name} -`, ...args);
								},

								logDebug: (...args) => {
									// debug(`Mechanic:${description.name} -`, ...args);
								},

								logInfo: (...args) => {
									info(`Mechanic:${description.name} -`, ...args);
								},

								logWarn: (...args) => {
									warn(`Mechanic:${description.name} -`, ...args);
								},

								logError: (...args) => {
									err(`Mechanic:${description.name} -`, ...args);
								},
							}),
						);
					},
					description,
					mechanicsFolder,
					descendant,
					mechId,
				);
			}
		}
	}
}
