import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage, RunService } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { connectActivation } from "core/../../kit/utils";
import { trace, warn } from "core/shared/log";

export class InstanceTag {
	readonly _instances = new Array<Instance>();
	readonly onLoadedCallbacks = new Set<(trove: Trove, instance: Instance) => void>();

	constructor(
		readonly tagName: string,
		readonly check?: t.check<Instance>,
	) {}

	instances(): Instance[] {
		return this._instances;
	}

	onLoaded(callback: (trove: Trove, instance: Instance) => void): void {
		this.onLoadedCallbacks.add(ty.Function.CastOrError(callback));
	}

	connectActivation(onActivated: (trove: Trove, instance: Instance, activationTrove: Trove) => void): void {
		ty.Function.CastOrError(onActivated);
		this.onLoadedCallbacks.add((trove, instance) => {
			connectActivation(trove, instance, onActivated);
		});
	}
}

export interface Kit {
	trove: Trove;
	tag(tagName: string, check?: t.check<Instance>): InstanceTag;
	onRender(callback: (trove: Trove, dt: number) => void): void;
	onPhysics(callback: (trove: Trove, dt: number) => void): void;
	onTick(callback: (trove: Trove, dt: number) => void): void;
}

export interface KitScript {
	type: "KitScript";
	run: (self: KitScript, kit: Kit) => void;
}

const KitScript = ty
	.Struct(
		{ exhaustive: false },
		{
			type: ty.Just("KitScript"),
			run: ty.Function,
		},
	)
	.Nicknamed("KitScript")
	.Retype<KitScript>();

const optionalCheck = ty.Function.Optional().Retype<Maybe<t.check<any>>>();

const MECHANIC_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("KitScripts"));

@Controller()
export class MechanicController implements OnInit {
	private scriptToModule = new Map<KitScript, Instance>();

	onInit(): void {
		for (const module of MECHANIC_MODULES_PARENT.getValue().GetDescendants()) {
			if (!classIs(module, "ModuleScript")) continue;

			const [requireSuccess, requireValue] = pcall(require, module);
			if (requireSuccess) {
				const maybe = KitScript.Cast(requireValue);
				if (maybe.some) {
					this.scriptToModule.set(requireValue as never, module);
					continue;
				}

				trace(
					"Ignoring module",
					module.GetFullName(),
					"because of bad type:",
					maybe.reason ?? "(no reason provided)",
				);

				continue;
			}

			warn("Cannot require kit script", module.GetFullName(), "because of:", tostring(requireValue));
		}
	}

	async loadMechanicsFromParent(trove: Trove, parent: Instance) {
		const tags = new Set<InstanceTag>();
		const onRenderCallbacks = new Array<(trove: Trove, dt: number) => void>();
		const onPhysicsCallbacks = new Array<(trove: Trove, dt: number) => void>();
		const onTickCallbacks = new Array<(trove: Trove, dt: number) => void>();

		const kit = table.freeze<Kit>({
			trove,
			tag(tagName: string, check: t.check<Instance> = t.Instance): InstanceTag {
				const instanceTag = new InstanceTag(ty.String.CastOrError(tagName), optionalCheck.CastOrError(check));
				tags.add(instanceTag);
				return instanceTag;
			},
			onRender(callback: (trove: Trove, dt: number) => void): void {
				onRenderCallbacks.push(ty.Function.CastOrError(callback));
			},
			onPhysics(callback: (trove: Trove, dt: number) => void): void {
				onPhysicsCallbacks.push(ty.Function.CastOrError(callback));
			},
			onTick(callback: (trove: Trove, dt: number) => void): void {
				onTickCallbacks.push(ty.Function.CastOrError(callback));
			},
		});

		for (const [script, module] of this.scriptToModule) {
			const [runSuccess, runError] = pcall(script.run, script, kit);
			if (!runSuccess) warn(`Cannot run kit script ${module.GetFullName()}: ${runError}`);
		}

		const tagLoadedThreads = new Array<thread>();
		async function tryTagInstance(instance: Instance, tag: InstanceTag) {
			if (tag.check && !tag.check(instance)) return;

			const instanceTrove = trove.extend();
			instanceTrove.attachToInstance(instance);

			// spawn loaded threads later so all instances can be tagged
			tagLoadedThreads.push(
				coroutine.create(() => {
					for (const loaded of tag.onLoadedCallbacks) {
						loaded(instanceTrove, instance);
					}
				}),
			);

			tag._instances.push(instance);
		}

		const tagPromises = new Array<Promise<void>>();
		for (const descendant of parent.GetDescendants()) {
			for (const t of tags) {
				if (descendant.HasTag(t.tagName)) tagPromises.push(tryTagInstance(descendant, t));
			}
		}

		await Promise.all(tagPromises);
		for (const thread of tagLoadedThreads) task.spawn(thread);

		trove.connect(RunService.PreRender, (dt) => {
			for (const render of onRenderCallbacks) render(trove, dt);
		});

		trove.connect(RunService.PreSimulation, (dt) => {
			for (const physics of onPhysicsCallbacks) physics(trove, dt);
		});

		trove.connect(RunService.PostSimulation, (dt) => {
			for (const tick of onTickCallbacks) tick(trove, dt);
		});
	}
}
