import { OnInit, Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import Make from "@rbxts/make";
import { Workspace } from "@rbxts/services";
import { t } from "@rbxts/t";
import audios from "core/shared/audios";
import { Blink } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";
import { areas } from "game/server/net";
import { AreaInfo, AreaInstance, NAME_TO_AREA } from "game/shared/areas";
import { PlayerService } from "./PlayerService";
import { TowerService } from "./TowerService";

export interface Area {
	info: AreaInfo;
	instance: Omit<AreaInstance, "Mechanics">;
	mechanics: AreaInstance["Mechanics"];
	spawn: AreaInstance["Spawn"];
}

interface PlayerAreaLoadingState {
	area: Area;
	instance: Instance;
	timeoutThread: thread;
}

const isAreaInstance = t.children({
	Mechanics: t.Instance,
	Towers: t.optional(t.Instance),
	Lobby: t.Instance,
	Spawn: t.instanceIsA("BasePart"),
	Lighting: t.optional(t.instanceIsA("Configuration")),
	DefaultBackgroundMusic: t.instanceIsA("Sound"),
}) satisfies t.check<AreaInstance>;

const CONFIRM_AREA_LOADED_TIMEOUT = 5;
const AREAS_WORKSPACE = new Lazy(() => Workspace.WaitForChild("Areas"));
const AREAS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "Areas" }));
const AREA_MECHANICS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "AreaMechanics" }));

@Service()
export class AreaService implements OnInit {
	private logger = createLogger("AreaService");

	private areas = new Set<Area>();
	private infoToArea = new Map<AreaInfo, Area>();
	private nameToArea = new Map<string, Area>();
	private loadingStates = new Map<Player, PlayerAreaLoadingState>();

	constructor(
		private towerService: TowerService,
		private playerService: PlayerService,
	) {}

	onInit(): void {
		const initPromises = new Array<Promise<void>>();
		for (const instance of AREAS_WORKSPACE.getValue().GetChildren()) initPromises.push(this.initArea(instance));
		Promise.all(initPromises).expect();
	}

	async initArea(instance: Instance) {
		this.logger.trace("Initializing area", instance.GetFullName());

		if (!isAreaInstance(instance)) {
			this.logger.warn(`Cannot initialize area ${instance.GetFullName()} because invalid instance tree`);
			return;
		}

		const info = NAME_TO_AREA.get(instance.Name);
		if (!info) {
			this.logger.warn(
				`Cannot initialize area ${instance.GetFullName()} because no matching AreaInfo in shared/areas.ts`,
			);
			return;
		}

		const area: Area = {
			info,
			instance,
			mechanics: instance.Mechanics,
			spawn: instance.Spawn,
		};

		const assetToUse = audios[instance.DefaultBackgroundMusic.GetAttribute("UseAudioAsset") as never] as string;
		if (assetToUse) {
			this.logger.trace("Using audio asset", assetToUse, "for", instance.GetFullName());
			instance.DefaultBackgroundMusic.SoundId = assetToUse;
		}
		instance.DefaultBackgroundMusic.SetAttribute("OriginalVolume", instance.DefaultBackgroundMusic.Volume);

		const towers = instance.Towers;
		if (towers) {
			this.logger.trace("Now initializing towers in areas");
			const initTowerPromises = new Array<Promise<void>>();
			for (const tower of towers.GetChildren()) initTowerPromises.push(this.towerService.initTower(tower));
			await Promise.all(initTowerPromises);
		}

		instance.Mechanics.Parent = AREA_MECHANICS_SERVER_STORAGE.getValue();
		instance.Parent = AREAS_SERVER_STORAGE.getValue();

		this.areas.add(area);
		this.infoToArea.set(info, area);
		this.nameToArea.set(info.name, area);
	}

	// NOTE: pointed out in #scripting-sancutary in EToH
	// https://discord.com/channels/551741409624064011/1131741516579213403/1360603684978950396
	// Need to ensure the player has cloned and loaded the area so we can
	// cleanup to avoid leaking memory
	@Blink(areas.confirmAreaLoaded)
	confirmAreaLoaded(player: Player): void {
		this.logger.trace(`${player.Name} confirmed area loaded client-side`);
		const state = this.loadingStates.get(player);
		if (!state) {
			this.logger.trace("...but the player already confirmed");
			return;
		}

		const { area, instance, timeoutThread } = state;

		this.logger.trace("Destroying loaded clone");
		instance.Destroy();

		this.logger.trace("Cancelling timeout thread");
		pcall(task.cancel, timeoutThread);

		// trace("Pivoting player");
		// const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
		// if (root) root.CFrame = area.spawn.CFrame.mul(new CFrame(0, 3, 0));
		player.LoadCharacter();
		const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
		if (root) root.CFrame = area.spawn.CFrame.mul(new CFrame(0, 3, 0));

		this.playerService.setInfo(player, "isLoadingArea", false);

		this.logger.trace("Cleaned up area loading server-side");
	}

	@Blink(areas.loadArea)
	loadArea(player: Player, areaName: string): Instance {
		this.logger.trace("Loading area", areaName, "for player", player.Name);
		const info = NAME_TO_AREA.get(areaName);

		if (!info) throw `No area named ${areaName}`;
		const area = this.infoToArea.get(info)!;

		if (this.playerService.getInfo(player).isLoadingArea) throw "Already loading area";
		this.playerService.setInfo(player, "isLoadingArea", true);
		this.playerService.setInfo(player, "currentArea", area);

		this.logger.trace("Cloning area");
		const instance = area.instance.Clone();
		area.mechanics.Clone().Parent = instance;

		this.logger.trace("Parenting to player");
		instance.Parent = player;

		this.loadingStates.set(player, {
			area,
			instance,
			timeoutThread: task.delay(
				CONFIRM_AREA_LOADED_TIMEOUT,
				(player) => {
					this.logger.trace(player.Name, "timed-out confirmation that area is loaded");
					this.confirmAreaLoaded(player);
				},
				player,
			),
		});

		this.logger.trace("Returning area");
		return instance;
	}
}
