import { OnInit, Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import { ServerStorage, Workspace } from "@rbxts/services";
import { t } from "@rbxts/t";
import { Blink } from "server/decorators";
import { areas } from "server/net";
import { Area, AREAS, NAME_TO_AREA } from "shared/constants/game";
import { trace } from "shared/log";

export interface AreaInstance extends Instance {
	Mechanics: Instance;
	Towers: Instance;
	Lobby: Instance;
	Spawn: BasePart;
}

const isAreaInstance = t.children({
	Mechanics: t.Instance,
	Towers: t.Instance,
	Lobby: t.Instance,
	Spawn: t.instanceIsA("BasePart"),
});

export interface TowerInstance extends Instance {
	Mechanics: Instance;
	Details: Instance;
	Obby: Instance;
	Spawn: BasePart;
}

const isTowerInstance = t.children({
	Mechanics: t.Instance,
	Details: t.Instance,
	Obby: t.Instance,
	Spawn: t.instanceIsA("BasePart"),
});

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

	onInit(): void {
		const areaFolder = Workspace.WaitForChild("Areas");
		for (const area of AREAS) {
			const instance = areaFolder.WaitForChild(area.name);
			assert(isAreaInstance(instance));

			this.areaToInstance.set(area, instance);
			instance.Parent = AREA_SERVER_STORAGE.getValue();

			for (const tower of instance.Towers.GetChildren()) {
				assert(isTowerInstance(tower));
				tower.Mechanics.Parent = TOWER_MECHANICS_STORAGE.getValue();
				tower.Obby.Parent = TOWER_OBBY_SERVER_STORAGE.getValue();
				tower.Details.Parent = TOWER_DETAILS_SERVER_STORAGE.getValue();
			}
		}

		areaFolder.Destroy();
	}

	@Blink(areas.loadArea)
	loadArea(player: Player, areaName: string): Instance {
		trace(`Loading area ${areaName} for player ${player.Name}`);
		const area = NAME_TO_AREA.get(areaName);
		if (!area) throw `No area named ${areaName}`;
		const areaInstance = this.areaToInstance.get(area)!;

		// HACK: only method of replicating is parenting to PlayerGui :(

		// const container = new Instance("ScreenGui");
		// container.Enabled = false;
		// container.ResetOnSpawn = false;
		// container.Name = areaName;

		const clone = areaInstance.Clone();
		// clone.Name = "AreaInstance";
		// clone.Parent = container;

		clone.Parent = player;

		task.defer(() => {
			const root = player.Character?.FindFirstChild<BasePart>("HumanoidRootPart");
			if (root) root.CFrame = areaInstance.Spawn.CFrame;
		});

		return clone;
	}
}
