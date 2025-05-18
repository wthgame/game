import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import { ReplicatedStorage } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Trove } from "@rbxts/trove";
import { prelude } from "core/../../kit/std";
import { LogBenchmark } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";

const { connectActivation } = prelude;

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

	onActivated(onActivated: (trove: Trove, instance: Instance, activationTrove: Trove) => void): void {
		ty.Function.CastOrError(onActivated);
		this.onLoadedCallbacks.add((trove, instance) => {
			connectActivation(trove, instance, onActivated);
		});
	}
}

export interface Kit {
	trove: Trove;
	mechanics: Instance;
	loadedAt: number;
	loadedLifetime(): number;
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

const MECHANIC_MODULES_PARENT = new Lazy(() => ReplicatedStorage.WaitForChild("KitObjects"));

@Controller()
export class KitObjectController implements OnInit {
	private logger = createLogger("KitObjectController");
	private scriptToModule = new Map<KitScript, Instance>();

	onInit(): void {
		for (const module of MECHANIC_MODULES_PARENT.getValue().GetDescendants()) {
			if (!classIs(module, "ModuleScript")) continue;

			const [requireSuccess, requireError] = pcall(require, module);
			if (!requireSuccess) {
				this.logger.warn(
					"Cannot require kit script",
					module.GetFullName(),
					"because of:",
					tostring(requireError),
				);
			}
		}
	}

	@LogBenchmark()
	async loadMechanicsFromParent(trove: Trove, parent: Instance) {
		for (const descendant of parent.GetDescendants()) {
			if (descendant.HasTag("KitObject")) {
				descendant.AddTag("__EXTREMELY_DANGEROUS_doNotRemove__wthShouldObserve");
			}
		}
	}
}
