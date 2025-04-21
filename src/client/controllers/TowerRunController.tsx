import { Controller, OnInit } from "@flamework/core";
import { atom } from "@rbxts/charm";
import ty from "@rbxts/libopen-ty";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { towers } from "client/net";
import { NAME_TO_TOWER, TowerInfo } from "shared/areas";
import { Blink } from "shared/decorators";
import { trace } from "shared/log";
import { MechanicController } from "./MechanicController";
import { addMechanicBinding } from "./MechanicController/bindings";

@Controller()
export class TowerRunController implements OnInit {
	private isLoaded = atom(false);
	readonly elapsedTime = atom(0);
	readonly currentTower = atom<TowerInfo>();

	constructor(private mechanicController: MechanicController) {}

	// onTick(): void {
	// 	if (!this.isLoaded()) return;
	// 	print("TIME:", math.round(this.elapsedTime() * 100) / 100);
	// }

	@Blink(towers.syncElapsedTime)
	syncElapsedTime(elapsedTime: number) {
		this.elapsedTime(elapsedTime);
	}

	onInit(): void {
		addMechanicBinding("TowerRunController.promptToStartNewTowerRun", (name) => {
			this.promptToLoadTower(ty.String.CastOrError(name));
		});
	}

	async promptToLoadTower(towerName: string): Promise<void> {
		trace(`Prompted to load tower named ${towerName}`);
		const info = NAME_TO_TOWER.get(towerName);
		if (!info) return;

		const tower = await towers.startTowerRun.invoke({ towerType: "Standard", towerName });
		if (tower) {
			tower.instance.Parent = Workspace;
			const trove = new Trove();
			trace("LOADING MECHANICS");
			this.mechanicController.loadMechanicsFromParent(trove, tower.mechanics);
			trace("DONE LOADING MECHANICS");
			this.isLoaded(true);
			this.currentTower(info);
		}
	}
}
