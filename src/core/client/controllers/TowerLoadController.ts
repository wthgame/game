import { Controller } from "@flamework/core";
import { Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { LogBenchmark } from "core/shared/decorators";
import { TowerInstance } from "core/shared/types";
import { BackgroundMusicController } from "./BackgroundMusicController";
import { MechanicController } from "./MechanicController";

@Controller()
export class TowerLoadController {
	constructor(
		private mechanicController: MechanicController,
		private backgroundMusicController: BackgroundMusicController,
	) {}

	@LogBenchmark()
	async loadTower(outerTrove: Trove, tower: TowerInstance) {
		const trove = outerTrove.extend();
		tower.Parent = Workspace;
		trove.add(tower);
		this.backgroundMusicController.consumeMusicZones(trove, tower.BackgroundMusicZones);
		await this.mechanicController.loadMechanicsFromParent(trove, tower.Mechanics);
		return tower;
	}
}
