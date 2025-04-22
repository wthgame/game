import { Controller, OnStart } from "@flamework/core";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { MechanicController } from "core/client/controllers/MechanicController";
import { onFlameworkExtinguished } from "core/shared/flamework";
import { confirmKitLoaded, loadKitMechanics } from "../net";

@Controller()
export class KitTowerClient implements OnStart {
	constructor(private mechanicController: MechanicController) {}

	async onStart(): Promise<void> {
		const mechanics = await loadKitMechanics.invoke();
		if (mechanics) {
			const clonedMechanics = mechanics.Clone();
			clonedMechanics.Parent = Workspace;

			confirmKitLoaded.fire();

			const trove = new Trove();
			this.mechanicController.loadMechanicsFromParent(trove, clonedMechanics);

			onFlameworkExtinguished(() => trove.clean());
		}
	}
}
