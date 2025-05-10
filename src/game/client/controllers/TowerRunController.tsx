import { Controller, OnInit } from "@flamework/core";
import { atom } from "@rbxts/charm";
import ty from "@rbxts/libopen-ty";
import { ContentProvider, ReplicatedStorage, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { LOADED_ZONE_TAG } from "core/client/controllers/BackgroundMusicController";
import { Blink } from "core/shared/decorators";
import { trace } from "core/shared/log";
import { BackgroundMusicZoneInstance, TowerInstance } from "core/shared/types";
import { towers } from "game/client/net";
import { NAME_TO_TOWER, TowerInfo } from "game/shared/areas";
import { MechanicController } from "../../../core/client/controllers/MechanicController";
import { addMechanicBinding } from "../../../core/client/controllers/MechanicController/bindings";

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
			// TODO: seperate into TowerLoaderController.ts to share
			// functionality with kit too

			const instance = tower.instance as Omit<TowerInstance, "Mechanics">;
			const mechanics = tower.mechanics as TowerInstance["Mechanics"];

			instance.Parent = Workspace;
			const trove = new Trove();
			trove.add(instance as Instance);

			trace("Loading mechanics");
			await this.mechanicController.loadMechanicsFromParent(trove, mechanics);
			trace("Finished loading mechanics");

			const bgmZones = instance.BackgroundMusicZones;
			for (const zone of bgmZones.GetChildren()) {
				if (BackgroundMusicZoneInstance(zone)) zone.AddTag(LOADED_ZONE_TAG);
			}

			bgmZones.Parent = ReplicatedStorage;
			bgmZones.Name += `_${towerName}`;
			trove.add(bgmZones);

			// TODO: proper preload service?
			task.spawn(preloadAsync, bgmZones.GetChildren());

			this.isLoaded(true);
			this.currentTower(info);
		}
	}
}
