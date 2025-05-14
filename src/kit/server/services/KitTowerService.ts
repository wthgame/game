import { OnInit, Service } from "@flamework/core";
import { ServerStorage, Workspace } from "@rbxts/services";
import { Blink } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";
import { castToTowerInstance, TowerInstance } from "core/shared/types";
import { confirmKitLoaded, loadKitMechanics } from "../net";

interface PlayerLoadingState {
	instance: Instance;
	timeoutThread: thread;
}

const CONFIRM_KIT_LOADED_TIMEOUT = 15;

@Service()
export class KitTowerService implements OnInit {
	private logger = createLogger("KitTowerService");

	private tower!: TowerInstance;
	private mechanics!: TowerInstance["Mechanics"];
	private hasKitMechanics = new Set<Player>();
	private loadingStates = new Map<Player, PlayerLoadingState>();

	onInit(): void {
		const maybeTowerInstance = castToTowerInstance(Workspace.WaitForChild("Kit"));
		if (maybeTowerInstance.some) {
			this.tower = maybeTowerInstance.value;
			this.mechanics = this.tower.Mechanics;
			this.mechanics.Parent = ServerStorage;
			return;
		}
		throw `Cannot initialize kit tower: ${maybeTowerInstance.reason}`;
	}

	@Blink(loadKitMechanics)
	loadKitMechanics(player: Player) {
		if (this.hasKitMechanics.has(player)) return;

		const clonedMechanics = this.mechanics.Clone();
		clonedMechanics.Parent = player;

		this.loadingStates.set(player, {
			instance: clonedMechanics,
			timeoutThread: task.delay(
				CONFIRM_KIT_LOADED_TIMEOUT,
				(player) => {
					this.logger.trace(player.Name, "timed-out confirmation that kit is loaded");
					this.confirmKitLoaded(player);
				},
				player,
			),
		});

		return clonedMechanics;
	}

	@Blink(confirmKitLoaded)
	confirmKitLoaded(player: Player): void {
		this.logger.trace(`${player.Name} confirmed kit loaded client-side`);
		const state = this.loadingStates.get(player);
		if (!state) {
			this.logger.trace("...but the player already confirmed");
			return;
		}

		const { instance, timeoutThread } = state;

		this.logger.trace("Destroying loaded clone");
		instance.Destroy();

		this.logger.trace("Cancelling timeout thread");
		pcall(task.cancel, timeoutThread);

		this.loadingStates.delete(player);
		this.logger.trace("Cleaned up kit loading server-side");

		this.hasKitMechanics.add(player);
	}
}
