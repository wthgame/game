import { Controller, OnStart } from "@flamework/core";
import Iris from "@rbxts/iris";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { DeveloperPanelDropdownRenderer } from "core/client/controllers/DeveloperPanelController";
import { KitObjectController } from "core/client/controllers/KitObjectController";
import { onFlameworkExtinguished } from "core/shared/flamework";
import { confirmKitLoaded, loadKitMechanics } from "../net";

@Controller()
export class KitTowerClient implements OnStart, DeveloperPanelDropdownRenderer {
	private isLoaded = false;

	constructor(private KitObjectController: KitObjectController) {}

	async onStart(): Promise<void> {
		const mechanics = await loadKitMechanics.invoke();
		if (mechanics) {
			const clonedMechanics = mechanics.Clone();
			clonedMechanics.Parent = Workspace;

			confirmKitLoaded.fire();

			const trove = new Trove();
			this.KitObjectController.loadMechanicsFromParent(trove, clonedMechanics);

			this.isLoaded = true;
			onFlameworkExtinguished(() => trove.clean());
		}
	}

	renderDeveloperPanelDropdown(): void {
		Iris.Text([this.isLoaded ? "Mechanics are loaded" : "Mechanics are NOT loaded"]);
	}
}
