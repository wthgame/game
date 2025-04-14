import { OnInit, Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import { ServerStorage, Workspace } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Blink } from "server/decorators";
import { areas } from "server/net";
import { Area, AREAS, NAME_TO_AREA, Tower } from "shared/constants/game";
import { trace } from "shared/log";

export interface AreaInstance {
	mechanics: Instance;
	towers?: Instance;
	lobby: Instance;
	spawn: BasePart;
	parent: Instance;
}

const isAreaInstance = t.children({
	Mechanics: t.Instance,
	Towers: t.optional(t.Instance),
	Lobby: t.Instance,
	Spawn: t.instanceIsA("BasePart"),
});

export interface TowerInstance {
	mechanics: Instance;
	details: Instance;
	obby: Instance;
	spawn: BasePart;
	parent: Instance;
}

const isTowerInstance = t.children({
	Mechanics: t.Instance,
	Details: t.Instance,
	Obby: t.Instance,
	Spawn: t.instanceIsA("BasePart"),
});

const CONFIRM_AREA_LOADED_TIMEOUT = 5;

export const AREA_SERVER_STORAGE = new Lazy(() => {
	const folder = new Instance("Folder");
	folder.Name = "Areas";
	folder.Parent = ServerStorage;
	return folder;
});

export const TOWER_DETAILS_SERVER_STORAGE = new Lazy(() => {
	const folder = new Instance("Folder");
	folder.Name = "TowerDetails";
	folder.Parent = ServerStorage;
	return folder;
});

export const TOWER_OBBY_SERVER_STORAGE = new Lazy(() => {
	const folder = new Instance("Folder");
	folder.Name = "TowerObby";
	folder.Parent = ServerStorage;
	return folder;
});

export const TOWER_MECHANICS_STORAGE = new Lazy(() => {
	const folder = new Instance("Folder");
	folder.Name = "TowerMechanics";
	folder.Parent = ServerStorage;
	return folder;
});

@Service()
export class WorldService implements OnInit {
	private areaToInstance = new Map<Area, AreaInstance>();
	private towerToInstance = new Map<Tower, TowerInstance>();

	private currentlyLoadingClones = new Map<Player, Instance>();

	onInit(): void {
		const areaFolder = Workspace.WaitForChild("Areas");
		for (const area of AREAS) {
			const areaInstance = areaFolder.WaitForChild(area.name);
			assert(isAreaInstance(areaInstance));

			this.areaToInstance.set(area, {
				mechanics: areaInstance.Mechanics,
				towers: areaInstance.Towers,
				lobby: areaInstance.Lobby,
				spawn: areaInstance.Spawn,
				parent: areaInstance,
			});

			areaInstance.Parent = AREA_SERVER_STORAGE.getValue();

			const towerFolder = areaInstance.Towers;
			if (area.towers && towerFolder) {
				for (const tower of area.towers) {
					const towerInstance: Instance = towerFolder.WaitForChild(tower.name);
					assert(isTowerInstance(towerInstance));

					this.towerToInstance.set(tower, {
						mechanics: towerInstance.Mechanics,
						obby: towerInstance.Obby,
						details: towerInstance.Details,
						spawn: towerInstance.Spawn,
						parent: towerInstance,
					});

					towerInstance.Mechanics.Parent = TOWER_MECHANICS_STORAGE.getValue();
					towerInstance.Obby.Parent = TOWER_OBBY_SERVER_STORAGE.getValue();
					towerInstance.Details.Parent = TOWER_DETAILS_SERVER_STORAGE.getValue();
				}
			}
		}

		areaFolder.Destroy();
	}

	// NOTE: pointed out in #scripting-sancutary in EToH
	// https://discord.com/channels/551741409624064011/1131741516579213403/1360603684978950396
	// Need to ensure the player has cloned and loaded the area so we can
	// cleanup to avoid leaking memory
	@Blink(areas.confirmAreaLoaded)
	confirmAreaLoaded(player: Player): void {
		trace(`${player.Name} confirmed area loaded client-side`);
		const clone = this.currentlyLoadingClones.get(player);

		if (!clone) {
			trace("...but there was no clone to destroy");
			return;
		}

		trace(`Destroying loaded clone`);
		this.currentlyLoadingClones.delete(player);
		clone.Destroy();
	}

	@Blink(areas.loadArea)
	loadArea(player: Player, areaName: string): Instance {
		trace(`Loading area ${areaName} for player ${player.Name}`);
		const area = NAME_TO_AREA.get(areaName);

		if (!area) throw `No area named ${areaName}`;
		const areaInstance = this.areaToInstance.get(area)!;

		const clone = new Instance("Folder");
		clone.Name = area.name;
		areaInstance.mechanics.Clone().Parent = clone;
		areaInstance.lobby.Clone().Parent = clone;
		areaInstance.spawn.Clone().Parent = clone;

		const towers = areaInstance.towers;
		if (towers) towers.Clone().Parent = clone;

		clone.Parent = player;
		this.currentlyLoadingClones.set(player, clone);

		task.defer(() => {
			trace(`Pivoting player`);
			const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
			if (root) root.CFrame = areaInstance.spawn.CFrame.mul(new CFrame(0, 3, 0));
		});

		task.delay(CONFIRM_AREA_LOADED_TIMEOUT, (player) => this.confirmAreaLoaded(player), player);

		return clone;
	}
}
