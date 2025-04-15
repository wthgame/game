import { Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import Maybe from "@rbxts/libopen-maybe";
import Make from "@rbxts/make";
import { NAME_TO_TOWER, TowerInfo, TowerInstance } from "shared/areas";
import { trace, warn } from "shared/log";

export interface Tower {
	info: TowerInfo;
	instance: Omit<TowerInstance, "Details" | "Obby" | "Mechanics">;
	obby: TowerInstance["Obby"];
	details: TowerInstance["Details"];
	mechanics: TowerInstance["Mechanics"];
	spawn: TowerInstance["Spawn"];
}

const TOWERS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "Tower" }));
const TOWER_OBBY_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerObby" }));
const TOWER_DETAILS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerDetails" }));
const TOWER_MECHANICS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerMechanics" }));

// TODO: remove link if not in studio
const NO_ETOH =
	"EToH kits with client objects aren't supported in Welcome To Hell, see section 1.1 'WTH for EToH' in The Tower Building Book:" +
	"\nhttps://welcome-to-hell.com/go/ttbb-1.1";

function castToTowerInstance(instance: Instance): Maybe.Maybe<TowerInstance> {
	const mechanics = instance.FindFirstChild("Mechanics");
	const details = instance.FindFirstChild("Details");
	const obby = instance.FindFirstChild("Obby");
	const spawn = instance.FindFirstChild("Spawn");

	if (!mechanics) {
		const clientSidedObjects = instance.FindFirstChild("ClientSidedObjects");
		if (clientSidedObjects) return Maybe.None(NO_ETOH);
		return Maybe.None("No Mechanics folder found");
	}

	if (!details) return Maybe.None("No Details folder found");
	if (!obby) return Maybe.None("No Obby folder found");
	if (!spawn) return Maybe.None("No Spawn found");
	if (!spawn.IsA("BasePart")) return Maybe.None(`Expected Spawn to be a BasePart, got ${spawn.ClassName}`);

	return Maybe.Some(instance as TowerInstance);
}

@Service()
export class TowerService {
	private towers = new Set<Tower>();
	private infoToTower = new Map<TowerInfo, Tower>();
	private nameToTower = new Map<string, Tower>();

	async initTower(instance: Instance) {
		trace("Initializing tower", instance.GetFullName());

		const info = NAME_TO_TOWER.get(instance.Name);
		if (!info) {
			warn("Cannot initialize tower", instance.GetFullName(), "because no matching TowerInfo in shared/areas.ts");
			return;
		}

		const maybeInstance = castToTowerInstance(instance);
		if (!maybeInstance.some) {
			warn(
				"Cannot initialize tower",
				instance.GetFullName(),
				"because invalid instance tree:",
				maybeInstance.reason,
			);

			return;
		}

		const towerInstance = maybeInstance.value;

		const tower: Tower = {
			info,
			instance: towerInstance,
			obby: towerInstance.Obby,
			details: towerInstance.Details,
			mechanics: towerInstance.Mechanics,
			spawn: towerInstance.Spawn,
		};

		towerInstance.Obby.Parent = TOWER_OBBY_SERVER_STORAGE.getValue();
		towerInstance.Details.Parent = TOWER_DETAILS_SERVER_STORAGE.getValue();
		towerInstance.Mechanics.Parent = TOWER_MECHANICS_SERVER_STORAGE.getValue();
		towerInstance.Parent = TOWERS_SERVER_STORAGE.getValue();

		this.towers.add(tower);
		this.infoToTower.set(info, tower);
		this.nameToTower.set(info.name, tower);
	}

	getTowers(): Set<Tower> {
		return this.towers;
	}

	getTowerFromInfo(info: TowerInfo): Maybe<Tower> {
		return this.infoToTower.get(info);
	}

	getTowerFromName(name: string): Maybe<Tower> {
		return this.nameToTower.get(name);
	}
}
