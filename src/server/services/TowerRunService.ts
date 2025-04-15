import { Service } from "@flamework/core";
import { Blink } from "server/decorators";
import { towers } from "server/net";
import { trace, warn } from "shared/log";
import { StartTowerRun, StartTowerRunResult } from "shared/types";
import { PlayerService } from "./PlayerService";
import { TowerService } from "./TowerService";

const CONFIRM_TOWER_LOADED_TIMEOUT = 5;

@Service()
export class TowerRunService {
	constructor(
		private towerService: TowerService,
		private playerService: PlayerService,
	) {}

	@Blink(towers.startTowerRun)
	startTowerRun(player: Player, unknownRunRequest: unknown) {
		const runStartedTime = os.clock();

		if (this.playerService.getInfo(player).isLoadingTower) {
			warn("Player", player, "wants to start a tower run, but player is already loading a tower");
			return;
		}

		const { towerType, towerName } = StartTowerRun.CastOrError(unknownRunRequest);
		trace("Player", player, "wants to start a tower run for", towerName);

		const tower = this.towerService.getTowerFromName(towerName);

		if (!tower) {
			warn("Cannot start run for player", player, "because tower", towerName, "does not exist");
			return;
		}

		this.playerService.setInfo(player, "isLoadingTower", true);
		this.playerService.setInfo(player, "currentTower", tower);
		this.playerService.setInfo(player, "runStartedTime", runStartedTime);

		const towerInstance = tower.instance.Clone();
		const mechanics = tower.mechanics.Clone();
		const obby = tower.obby.Clone();
		mechanics.Parent = towerInstance;
		obby.Parent = towerInstance;
		towerInstance.Parent = player;

		const result: StartTowerRunResult = {
			instance: towerInstance,
			mechanics: mechanics,
		};

		// Just in case the player is doing some stupid respawning bs
		player.LoadCharacter();
		const character = player.Character || player.CharacterAdded.Wait()[0];

		character.FindFirstChildOfClass("ForceField")?.Destroy();
		character.PivotTo(tower.spawn.CFrame.mul(new CFrame(0, 3, 0)));

		this.playerService.setInfo(player, "isLoadingTower", false);

		return result;
	}
}
