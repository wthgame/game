import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage, RunService } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { warn } from "core/shared/log";

export class InstanceTag {
	readonly _instances = new Array<Instance>();
	readonly onLoadedCallbacks = new Set<(trove: Trove, instance: Instance) => void>();
	readonly onUnloadedCallbacks = new Set<(trove: Trove, instance: Instance) => void>();

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

	onUnloaded(callback: (trove: Trove, instance: Instance) => void): void {
		this.onUnloadedCallbacks.add(ty.Function.CastOrError(callback));
	}
}

export interface WTH {
	tag(tagName: string, check?: t.check<Instance>): InstanceTag;
	onRender(callback: (trove: Trove, dt: number) => void): void;
	onPhysics(callback: (trove: Trove, dt: number) => void): void;
	onTick(callback: (trove: Trove, dt: number) => void): void;
	onMechanicsLoaded(callback: (trove: Trove) => void): void;
	onMechanicsUnloaded(callback: (trove: Trove) => void): void;
}

const optionalCheck = ty.Function.Optional().Retype<Maybe<t.check<any>>>();

const MECHANIC_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("Mechanics"));

@Controller()
export class MechanicController implements OnInit {
	private initToModule = new Map<(wth: WTH) => void, Instance>();

	onInit(): void {
		for (const module of MECHANIC_MODULES_PARENT.getValue().GetDescendants()) {
			if (!classIs(module, "ModuleScript")) continue;

			const [requireSuccess, requireValue] = pcall(require, module);
			if (requireSuccess) {
				const maybe = ty.Function.Cast(requireValue);
				if (maybe.some) {
					this.initToModule.set(maybe.value, module);
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
	}

	async loadMechanicsFromParent(trove: Trove, parent: Instance) {
		const tags = new Set<InstanceTag>();
		const onRenderCallbacks = new Array<(trove: Trove, dt: number) => void>();
		const onPhysicsCallbacks = new Array<(trove: Trove, dt: number) => void>();
		const onTickCallbacks = new Array<(trove: Trove, dt: number) => void>();
		const onMechanicsLoadedCallbacks = new Array<(trove: Trove) => void>();
		const onMechanicsUnloadedCallbacks = new Array<(trove: Trove) => void>();

		const wth = table.freeze<WTH>({
			tag(tagName: string, check?: t.check<Instance>): InstanceTag {
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
			onMechanicsLoaded(callback: (trove: Trove) => void): void {
				onMechanicsLoadedCallbacks.push(ty.Function.CastOrError(callback));
			},
			onMechanicsUnloaded(callback: (trove: Trove) => void): void {
				onMechanicsUnloadedCallbacks.push(ty.Function.CastOrError(callback));
			},
		});

		for (const [init, module] of this.initToModule) {
			const [initSuccess, initError] = pcall(init, wth);
			if (!initSuccess) warn(`Cannot initialize module ${module.GetFullName()}: ${initError}`);
		}

		const tagLoadedThreads = new Array<thread>();
		async function tryTagInstance(instance: Instance, tag: InstanceTag) {
			if (tag.check && !tag.check(instance)) return;

			const instanceTrove = trove.extend();
			instanceTrove.attachToInstance(instance);

			tagLoadedThreads.push(
				coroutine.create(() => {
					for (const loaded of tag.onLoadedCallbacks) {
						loaded(instanceTrove, instance);
					}
				}),
			);

			instanceTrove.add(() => {
				for (const unloaded of tag.onUnloadedCallbacks) {
					unloaded(instanceTrove, instance);
				}
			});

			tag._instances.push(instance);
		}

		const tagPromises = new Array<Promise<void>>();
		for (const descendant of parent.GetDescendants()) {
			for (const t of tags) {
				if (descendant.HasTag(t.tagName)) {
					tagPromises.push(tryTagInstance(descendant, t));
				}
			}
		}

		await Promise.all(tagPromises);
		for (const thread of tagLoadedThreads) task.spawn(thread);

		if (onRenderCallbacks.size() > 0) {
			trove.connect(RunService.PreRender, (dt) => {
				for (const render of onRenderCallbacks) {
					render(trove, dt);
				}
			});
		}

		if (onPhysicsCallbacks.size() > 0) {
			trove.connect(RunService.PreSimulation, (dt) => {
				for (const render of onPhysicsCallbacks) {
					render(trove, dt);
				}
			});
		}

		if (onTickCallbacks.size() > 0) {
			trove.connect(RunService.PostSimulation, (dt) => {
				for (const render of onTickCallbacks) {
					render(trove, dt);
				}
			});
		}

		if (onMechanicsLoadedCallbacks.size() > 0) {
			for (const mechanicsLoaded of onMechanicsLoadedCallbacks) {
				mechanicsLoaded(trove);
			}
		}

		if (onMechanicsUnloadedCallbacks.size() > 0) {
			trove.add(() => {
				for (const mechanicsUnloaded of onMechanicsUnloadedCallbacks) {
					mechanicsUnloaded(trove);
				}
			});
		}
	}
}
