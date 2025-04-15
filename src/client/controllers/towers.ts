import { Controller, OnInit } from "@flamework/core";
import ty from "@rbxts/libopen-ty";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { towers } from "client/net";
import { trace } from "shared/log";
import { MechanicController } from "./mechanics";
import { addMechanicBinding } from "./mechanics/bindings";

@Controller()
export class TowersController implements OnInit {
	constructor(private mechanicController: MechanicController) {}

	onInit(): void {
		addMechanicBinding("TowersController.promptToLoadTower", (name) => {
			this.promptToLoadTower(ty.String.CastOrError(name));
		});
	}

	async promptToLoadTower(towerName: string): Promise<void> {
		trace(`Prompted to load tower named ${towerName}`);
		const tower = await towers.startTowerRun.invoke({ towerType: "Standard", towerName });
		if (tower) {
			tower.instance.Parent = Workspace;
			const trove = new Trove();
			this.mechanicController.loadMechanicsFromParent(trove, tower.mechanics);
		}
	}
}
