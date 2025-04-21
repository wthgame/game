import { OnInit, Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import Make from "@rbxts/make";
import { Workspace } from "@rbxts/services";
import { t } from "@rbxts/t";
import { areas } from "game/server/net";
import { AreaInfo, AreaInstance, NAME_TO_AREA } from "game/shared/areas";
import { Blink } from "game/shared/decorators";
import { trace, warn } from "game/shared/log";
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
}) as t.check<AreaInstance>;

const CONFIRM_AREA_LOADED_TIMEOUT = 5;
const AREAS_WORKSPACE = new Lazy(() => Workspace.WaitForChild("Areas"));
const AREAS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "Areas" }));
const AREA_MECHANICS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "AreaMechanics" }));

@Service()
export class AreaService implements OnInit {
	private areas = new Set<Area>();
	private infoToArea = new Map<AreaInfo, Area>();
	private nameToArea = new Map<string, Area>();
	private loadingStates = new Map<Player, PlayerAreaLoadingState>();

	constructor(private towerService: TowerService) {}

	onInit(): void {
		const initPromises = new Array<Promise<void>>();
		for (const instance of AREAS_WORKSPACE.getValue().GetChildren()) initPromises.push(this.initArea(instance));
		Promise.all(initPromises).expect();
	}

	async initArea(instance: Instance) {
		trace("Initializing area", instance.GetFullName());

		if (!isAreaInstance(instance)) {
			warn(`Cannot initialize area ${instance.GetFullName()} because invalid instance tree`);
			return;
		}

		const info = NAME_TO_AREA.get(instance.Name);
		if (!info) {
			warn(`Cannot initialize area ${instance.GetFullName()} because no matching AreaInfo in shared/areas.ts`);
			return;
		}

		const area: Area = {
			info,
			instance,
			mechanics: instance.Mechanics,
			spawn: instance.Spawn,
		};

		const towers = instance.Towers;
		if (towers) {
			trace("Now initializing towers in areas");
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
		trace(`${player.Name} confirmed area loaded client-side`);
		const state = this.loadingStates.get(player);
		if (!state) {
			trace("...but the player already confirmed");
			return;
		}

		const { area, instance, timeoutThread } = state;

		trace("Destroying loaded clone");
		instance.Destroy();

		trace("Cancelling timeout thread");
		pcall(task.cancel, timeoutThread);

		trace("Pivoting player");
		const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
		if (root) root.CFrame = area.spawn.CFrame.mul(new CFrame(0, 3, 0));

		trace("Cleaned up area loading server-side");
	}

	@Blink(areas.loadArea)
	loadArea(player: Player, areaName: string): Instance {
		trace("Loading area", areaName, "for player", player.Name);
		const info = NAME_TO_AREA.get(areaName);

		if (!info) throw `No area named ${areaName}`;
		const area = this.infoToArea.get(info)!;

		trace("Cloning area");
		const instance = area.instance.Clone();
		area.mechanics.Clone().Parent = instance;

		trace("Parenting to player");
		instance.Parent = player;

		this.loadingStates.set(player, {
			area,
			instance,
			timeoutThread: task.delay(
				CONFIRM_AREA_LOADED_TIMEOUT,
				(player) => {
					trace(player.Name, "timed-out confirmation that area is loaded");
					this.confirmAreaLoaded(player);
				},
				player,
			),
		});

		trace("Returning area");
		return instance;
	}
}
