import { OnInit, Service } from "@flamework/core";
import { Players } from "@rbxts/services";
import { Tower } from "./TowerService";

export interface PlayerInfo {
	player: Player;

	isLoadingTower: boolean;
	currentTower?: Tower;
	runStartedTime?: number;
}

@Service()
export class PlayerService implements OnInit {
	public infos = new Map<Player, PlayerInfo>();

	onInit() {
		Players.PlayerAdded.Connect((player) => {
			this.infos.set(player, {
				player,
				isLoadingTower: false,
				currentTower: undefined,
				runStartedTime: undefined,
			});
		});

		Players.PlayerRemoving.Connect((player) => {
			this.infos.delete(player);
		});
	}

	setInfo<K extends keyof PlayerInfo>(player: Player, key: K, value: PlayerInfo[K]) {
		const info = this.infos.get(player);
		if (info) {
			info[key] = value;
		}
	}

	getInfo(player: Player): PlayerInfo {
		return this.infos.get(player)!;
	}
}
