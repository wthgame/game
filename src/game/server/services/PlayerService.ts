import { OnInit, Service } from "@flamework/core";
import { Players } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import { Area } from "./AreaService";
import { Tower } from "./TowerService";

export interface PlayerInfo {
	trove: Trove;
	player: Player;

	isLoadingTower: boolean;
	currentTower?: Tower;
	runStartedTime?: number;

	isLoadingArea: boolean;
	currentArea?: Area;
}

@Service()
export class PlayerService implements OnInit {
	public infos = new Map<Player, PlayerInfo>();

	onInit() {
		Players.PlayerAdded.Connect((player) => {
			const trove = new Trove();
			this.infos.set(player, {
				trove,
				player,
				isLoadingTower: false,
				currentTower: undefined,
				runStartedTime: undefined,
				isLoadingArea: false,
				currentArea: undefined,
			});

			trove.connect(player.CharacterAdded, () => {
				const { currentArea, isLoadingArea } = this.getInfo(player);
				if (!isLoadingArea && currentArea) {
					const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
					if (root) root.CFrame = currentArea.spawn.CFrame.mul(new CFrame(0, 3, 0));
				}
			});
		});

		Players.PlayerRemoving.Connect((player) => {
			this.infos.get(player)?.trove.clean();
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
