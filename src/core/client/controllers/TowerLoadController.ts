import { Controller } from "@flamework/core";
import { ContentProvider, ReplicatedStorage, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { LogBenchmark } from "core/shared/decorators";
import { BackgroundMusicZoneInstance, TowerInstance } from "core/shared/types";
import { LOADED_ZONE_TAG } from "./BackgroundMusicController";
import { MechanicController } from "./MechanicController";

function preloadAsync(
	contentIdList: Array<Instance | string>,
	callback?: (contentId: string, status: Enum.AssetFetchStatus) => void,
) {
	ContentProvider.PreloadAsync(contentIdList, callback);
}

@Controller()
export class TowerLoadController {
	constructor(private mechanicController: MechanicController) {}

	@LogBenchmark()
	async loadTower(outerTrove: Trove, tower: TowerInstance) {
		const trove = outerTrove.extend();

		tower.Parent = Workspace;
		trove.add(tower);

		const bgmZones = tower.BackgroundMusicZones;
		for (const zone of bgmZones.GetChildren()) {
			if (BackgroundMusicZoneInstance(zone)) zone.AddTag(LOADED_ZONE_TAG);
		}
		bgmZones.Parent = ReplicatedStorage;
		bgmZones.Name += `_${tower.Name}`;
		trove.add(bgmZones);
		task.spawn(preloadAsync, bgmZones.GetChildren());

		await this.mechanicController.loadMechanicsFromParent(trove, tower.Mechanics);

		return tower;
	}
}
