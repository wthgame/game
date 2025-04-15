import { Controller, OnInit, OnTick } from "@flamework/core";
import { atom } from "@rbxts/charm";
import ty from "@rbxts/libopen-ty";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { towers } from "client/net";
import { Blink } from "shared/decorators";
import { trace } from "shared/log";
import { MechanicController } from "./mechanics";
import { addMechanicBinding } from "./mechanics/bindings";

@Controller()
export class TowersController implements OnInit, OnTick {
	private isLoaded = atom(false);
	private elapsedTime = atom(0);

	constructor(private mechanicController: MechanicController) {}

	onTick(): void {
		if (!this.isLoaded()) return;
		print("TIME:", math.round(this.elapsedTime() * 100) / 100);
	}

	@Blink(towers.syncElapsedTime)
	syncElapsedTime(elapsedTime: number) {
		this.elapsedTime(elapsedTime);
	}

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
			this.isLoaded(true);
		}
	}
}
