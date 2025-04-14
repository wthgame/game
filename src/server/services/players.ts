import { OnInit, Service } from "@flamework/core";
import { Players } from "@rbxts/services";
import { Tower } from "shared/constants/game";

export interface PlayerInfo {
	player: Player;

	currentTower?: Tower;
	runStarted?: number;
}

@Service()
export class PlayersService implements OnInit {
	public infos: Map<Player, PlayerInfo> = new Map();

	onInit() {
		Players.PlayerAdded.Connect((player) => {
			this.infos.set(player, {
				player,
				currentTower: undefined,
				runStarted: undefined,
			});
		});

		Players.PlayerRemoving.Connect((player) => {
			this.infos.delete(player);
		});
	}
}
