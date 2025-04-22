import { OnInit, Service } from "@flamework/core";
import Maybe from "@rbxts/libopen-maybe";
import { ServerStorage, Workspace } from "@rbxts/services";
import { Blink } from "core/shared/decorators";
import { trace } from "core/shared/log";
import { TowerInstance } from "kit/shared/types";
import { confirmKitLoaded, loadKitMechanics } from "../net";

interface PlayerLoadingState {
	instance: Instance;
	timeoutThread: thread;
}

// TODO: remove link if not in studio
const NO_ETOH =
	"EToH kits with client objects aren't supported in Welcome To Hell, see section 1.1 'WTH for EToH' in The Tower Building Book:" +
	"\nhttps://welcome-to-hell.com/go/ttbb-1.1";

const CONFIRM_KIT_LOADED_TIMEOUT = 15;

function castToTowerInstance(instance: Instance): Maybe.Maybe<TowerInstance> {
	const mechanics = instance.FindFirstChild("Mechanics");
	const decoration = instance.FindFirstChild("Decoration");
	const obby = instance.FindFirstChild("Obby");
	const spawn = instance.FindFirstChild("Spawn");

	if (!mechanics) {
		const clientSidedObjects = instance.FindFirstChild("ClientSidedObjects");
		if (clientSidedObjects) return Maybe.None(NO_ETOH);
		return Maybe.None("No Mechanics folder found");
	}

	if (!decoration) return Maybe.None("No Decoration folder found");
	if (!obby) return Maybe.None("No Obby folder found");
	if (!spawn) return Maybe.None("No Spawn found");
	if (!spawn.IsA("BasePart")) return Maybe.None(`Expected Spawn to be a BasePart, got ${spawn.ClassName}`);

	return Maybe.Some(instance as TowerInstance);
}

@Service()
export class KitTowerService implements OnInit {
	private tower!: TowerInstance;
	private mechanics!: TowerInstance["Mechanics"];
	private hasKitMechanics = new Set<Player>();
	private loadingStates = new Map<Player, PlayerLoadingState>();

	onInit(): void {
		const maybeTowerInstance = castToTowerInstance(Workspace.WaitForChild("Welcome To Hell Kit v1.0.0"));
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
					trace(player.Name, "timed-out confirmation that kit is loaded");
					this.confirmKitLoaded(player);
				},
				player,
			),
		});

		return clonedMechanics;
	}

	@Blink(confirmKitLoaded)
	confirmKitLoaded(player: Player): void {
		trace(`${player.Name} confirmed kit loaded client-side`);
		const state = this.loadingStates.get(player);
		if (!state) {
			trace("...but the player already confirmed");
			return;
		}

		const { instance, timeoutThread } = state;

		trace("Destroying loaded clone");
		instance.Destroy();

		trace("Cancelling timeout thread");
		pcall(task.cancel, timeoutThread);

		this.loadingStates.delete(player);
		trace("Cleaned up kit loading server-side");

		this.hasKitMechanics.add(player);
	}
}
