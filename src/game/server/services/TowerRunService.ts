import { OnTick, Service } from "@flamework/core";
import { Blink } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";
import { towers } from "game/server/net";
import { StartTowerRun } from "game/shared/types";
import { PlayerService } from "./PlayerService";
import { TowerService } from "./TowerService";

const CONFIRM_TOWER_LOADED_TIMEOUT = 5;

@Service()
export class TowerRunService implements OnTick {
	private logger = createLogger("TowerRunService");

	constructor(
		private towerService: TowerService,
		private playerService: PlayerService,
	) {}

	onTick(): void {
		const now = os.clock();
		for (const [player, { runStartedTime }] of pairs(this.playerService.infos)) {
			if (!runStartedTime) continue;
			towers.syncElapsedTime.fire(player, now - runStartedTime);
		}
	}

	@Blink(towers.startTowerRun)
	startTowerRun(player: Player, unknownRunRequest: unknown) {
		const runStartedTime = os.clock();

		if (this.playerService.getInfo(player).isLoadingTower) {
			this.logger.warn("Player", player, "wants to start a tower run, but player is already loading a tower");
			return;
		}

		const { towerType, towerName } = StartTowerRun.CastOrError(unknownRunRequest);
		this.logger.trace("Player", player, "wants to start a tower run for", towerName);

		const tower = this.towerService.getTowerFromName(towerName);

		if (!tower) {
			this.logger.warn("Cannot start run for player", player, "because tower", towerName, "does not exist");
			return;
		}

		this.playerService.setInfo(player, "isLoadingTower", true);
		this.playerService.setInfo(player, "currentTower", tower);
		this.playerService.setInfo(player, "runStartedTime", runStartedTime);

		const towerInstance = tower.instance.Clone();
		const mechanics = tower.mechanics.Clone();
		const obby = tower.obby.Clone();
		const decoration = tower.decoration.Clone();
		const bgmZones = tower.bgmZones.Clone();
		mechanics.Parent = towerInstance;
		obby.Parent = towerInstance;
		decoration.Parent = towerInstance;
		bgmZones.Parent = towerInstance;
		towerInstance.Parent = player;

		// Just in case the player is doing some stupid respawning bs
		player.LoadCharacter();
		const character = player.Character || player.CharacterAdded.Wait()[0];

		character.FindFirstChildOfClass("ForceField")?.Destroy();
		character.PivotTo(tower.spawn.CFrame.mul(new CFrame(0, 3, 0)));

		this.playerService.setInfo(player, "isLoadingTower", false);

		return towerInstance;
	}
}
