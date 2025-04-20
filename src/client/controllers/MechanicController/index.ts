import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import Object from "@rbxts/object-utils";
import { ReplicatedStorage, RunService } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { err, trace, warn } from "shared/log";

export interface Mechanic {
	type: "Mechanic";
	minimumKitVersion?: string;
	instanceTag: string;
	instanceCheck?: t.check<any>;
	defaultAttributes: Map<string, any>;
	attributeChecks: Map<string, t.check<any>>;
	persistent?: boolean;

	loaded?: (mechanic: MechanicContext, trove: Trove, instance: Instance, kit: KitContext) => void;
	unloaded?: (mechanic: MechanicContext, trove: Trove, instance: Instance, kit: KitContext) => void;
	kitLoaded?: (mechanic: MechanicContext, trove: Trove, kit: KitContext) => void;
	kitUnloaded?: (mechanic: MechanicContext, trove: Trove, kit: KitContext) => void;
	renderStepped?: (mechanic: MechanicContext, trove: Trove, dt: number, kit: KitContext) => void;
	physicStepped?: (mechanic: MechanicContext, trove: Trove, dt: number, kit: KitContext) => void;
}

const Mechanic = ty
	.Struct(
		{ exhaustive: true },
		{
			type: ty.Just("Mechanic"),
			minimumKitVersion: ty.String.Optional(),
			instanceTag: ty.String,
			instanceCheck: ty.Function.Optional(),
			defaultAttributes: ty.MapOf(ty.String, ty.Unknown),
			attributeChecks: ty.MapOf(ty.String, ty.Function),
			persistent: ty.Boolean.Optional(),
			loaded: ty.Function.Optional(),
			unloaded: ty.Function.Optional(),
			kitLoaded: ty.Function.Optional(),
			kitUnloaded: ty.Function.Optional(),
			renderStepped: ty.Function.Optional(),
			physicStepped: ty.Function.Optional(),
		},
	)
	.Nicknamed("Mechanic")
	.Retype<Mechanic>();

export interface WTH {
	registerMechanic: (...mechanics: Mechanic[]) => void;
}

export class KitContext {
	isDebug(): boolean {
		throw "not yet implemented";
	}
}

export class MechanicContext {
	constructor(
		private _mechanic: Mechanic,
		private _taggedInstances: Map<Mechanic, Instance[]>,
	) {}

	instances(): Instance[] {
		return this._taggedInstances.get(this._mechanic) ?? [];
	}

	attribute(instance: Instance, key: string): unknown {
		ty.String.CastOrError(key);
		const realValue = instance.GetAttribute(key);
		const check = this._mechanic.attributeChecks.get(key);

		if (check && check(realValue)) {
			return realValue;
		}

		return this._mechanic.defaultAttributes.get(key);
	}
}

const MECHANIC_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

@Controller()
export class MechanicController implements OnInit {
	private mechanics = new Set<Mechanic>();

	onInit(): void {
		const initToModule = new Map<(wth: WTH) => void, Instance>();

		for (const module of MECHANIC_MODULES_PARENT.getValue().GetDescendants()) {
			if (!classIs(module, "ModuleScript")) continue;

			const [requireSuccess, requireValue] = pcall(require, module);
			if (requireSuccess) {
				const maybe = ty.Function.Cast(requireValue);
				if (maybe.some) {
					initToModule.set(maybe.value, module);
					continue;
				}

				warn(
					"Ignoring module",
					module.GetFullName(),
					"because it is not a function:",
					maybe.reason ?? "(no reason provided)",
				);

				continue;
			}

			warn("Cannot require mechanic module", module.GetFullName(), "because of:", tostring(requireValue));
		}

		const wth = table.freeze<WTH>({
			registerMechanic: (...mechanics: Mechanic[]): void => {
				for (const mechanic of mechanics) {
					this.mechanics.add(Mechanic.CastOrError(mechanic));
				}
			},
		});

		async function doInit(init: (wth: WTH) => void) {
			init(wth);
		}

		const initPromises = new Array<Promise<void>>();
		for (const [init, module] of initToModule) {
			initPromises.push(
				doInit(init).catch((reason) =>
					err("Cannot initialize mechanic module", module.GetFullName(), "because of:", reason),
				),
			);
		}

		Promise.all(initPromises).expect();

		trace(
			"Initialized mechanics:",
			Object.keys(this.mechanics)
				.map(({ instanceTag }) => instanceTag)
				.join(", "),
		);
	}

	// TODO: clean this up wtf
	async loadMechanicsFromParent(trove: Trove, parent: Instance) {
		const taggedInstances = new Map<Mechanic, Instance[]>();

		const mechanicContexts = new Map<Mechanic, MechanicContext>();
		for (const mechanic of this.mechanics) {
			mechanicContexts.set(mechanic, new MechanicContext(mechanic, taggedInstances));
		}

		const kitContext = new KitContext();

		async function tryLoadMechanic(outerTrove: Trove, mechanic: Mechanic, instance: Instance) {
			if (mechanic.instanceCheck && !mechanic.instanceCheck(instance)) return;

			const trove = outerTrove.extend();
			trove.attachToInstance(instance);

			if (!taggedInstances.has(mechanic)) taggedInstances.set(mechanic, []);
			taggedInstances.get(mechanic)!.push(instance);
			// trove.add(() => taggedInstances.get(mechanic)?.delete(instance));

			if (!mechanicContexts.has(mechanic)) {
				mechanicContexts.set(mechanic, new MechanicContext(mechanic, taggedInstances));
			}

			if (mechanic.loaded) {
				task.spawn(mechanic.loaded, mechanicContexts.get(mechanic)!, trove, instance, kitContext);
			}
		}

		const loadPromises = new Array<Promise<void>>();
		for (const descendant of parent.GetDescendants()) {
			for (const mechanic of this.mechanics) {
				if (descendant.HasTag(mechanic.instanceTag)) {
					loadPromises.push(tryLoadMechanic(trove, mechanic, descendant));
				}
			}
		}

		trove.add(
			RunService.PreRender.Connect((dt) => {
				for (const mechanic of this.mechanics) {
					if (mechanic.renderStepped) {
						task.spawn(mechanic.renderStepped, mechanicContexts.get(mechanic)!, trove, dt, kitContext);
					}
				}
			}),
		);

		trove.add(
			RunService.PreSimulation.Connect((dt) => {
				for (const mechanic of this.mechanics) {
					if (mechanic.physicStepped) {
						task.spawn(mechanic.physicStepped, mechanicContexts.get(mechanic)!, trove, dt, kitContext);
					}
				}
			}),
		);

		for (const mechanic of this.mechanics) {
			if (mechanic.kitLoaded) {
				task.spawn(mechanic.kitLoaded, mechanicContexts.get(mechanic)!, trove, kitContext);
			}
		}

		Promise.all(loadPromises).expect();
	}
}
