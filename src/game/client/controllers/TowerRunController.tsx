import { Controller, OnInit } from "@flamework/core";
import { atom } from "@rbxts/charm";
import ty from "@rbxts/libopen-ty";
import { ContentProvider } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { addKitBinding } from "core/client/controllers/KitObjectController/bindings";
import { TowerLoadController } from "core/client/controllers/TowerLoadController";
import { Blink, LogBenchmark } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";
import { TowerInstance } from "core/shared/types";
import { towers } from "game/client/net";
import { NAME_TO_TOWER, TowerInfo } from "game/shared/areas";

function preloadAsync(
	contentIdList: Array<Instance | string>,
	callback?: (contentId: string, status: Enum.AssetFetchStatus) => void,
) {
	ContentProvider.PreloadAsync(contentIdList, callback);
}

@Controller()
export class TowerRunController implements OnInit {
	private isLoaded = atom(false);
	readonly elapsedTime = atom(0);
	readonly currentTower = atom<TowerInfo>();

	private logger = createLogger("TowerRunController");

	constructor(private towerLoadController: TowerLoadController) {}

	@Blink(towers.syncElapsedTime)
	syncElapsedTime(elapsedTime: number) {
		this.elapsedTime(elapsedTime);
	}

	onInit(): void {
		addKitBinding("@game/TowerRunController/promptToLoadTower", (name) => {
			this.promptToLoadTower(ty.String.CastOrError(name));
		});
	}

	@LogBenchmark()
	async promptToLoadTower(towerName: string): Promise<void> {
		this.logger.trace(`Prompted to load tower named ${towerName}`);
		const info = NAME_TO_TOWER.get(towerName);
		if (!info) return;
		const tower = await towers.startTowerRun.invoke({ towerType: "Standard", towerName });
		if (tower) {
			const trove = new Trove();
			await this.towerLoadController.loadTower(trove, tower as TowerInstance);
			this.isLoaded(true);
			this.currentTower(info);
		}
	}
}
