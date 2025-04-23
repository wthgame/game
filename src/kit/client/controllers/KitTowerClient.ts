import { Controller, OnStart } from "@flamework/core";
import Iris from "@rbxts/iris";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { DeveloperPanelDropdownRenderer } from "core/client/controllers/DeveloperPanelController";
import { MechanicController } from "core/client/controllers/MechanicController";
import { onFlameworkExtinguished } from "core/shared/flamework";
import { confirmKitLoaded, loadKitMechanics } from "../net";

@Controller()
export class KitTowerClient implements OnStart, DeveloperPanelDropdownRenderer {
	private isLoaded = false;

	constructor(private mechanicController: MechanicController) {}

	async onStart(): Promise<void> {
		const mechanics = await loadKitMechanics.invoke();
		if (mechanics) {
			const clonedMechanics = mechanics.Clone();
			clonedMechanics.Parent = Workspace;

			confirmKitLoaded.fire();

			const trove = new Trove();
			this.mechanicController.loadMechanicsFromParent(trove, clonedMechanics);

			this.isLoaded = true;
			onFlameworkExtinguished(() => trove.clean());
		}
	}

	renderDeveloperPanelDropdown(): void {
		Iris.Text([this.isLoaded ? "Mechanics are loaded" : "Mechanics are NOT loaded"]);
	}
}
