import { Service } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import Maybe from "@rbxts/libopen-maybe";
import Make from "@rbxts/make";
import audios from "core/shared/audios";
import { createLogger } from "core/shared/logger";
import { BackgroundMusicZoneInstance, castToTowerInstance } from "core/shared/types";
import { NAME_TO_TOWER, TowerInfo, TowerInstance } from "game/shared/areas";

export interface Tower {
	info: TowerInfo;
	instance: Omit<TowerInstance, "Decoration" | "Obby" | "Mechanics">;
	obby: TowerInstance["Obby"];
	decoration: TowerInstance["Decoration"];
	mechanics: TowerInstance["Mechanics"];
	bgmZones: TowerInstance["BackgroundMusicZones"];
	spawn: TowerInstance["Spawn"];
}

// const TOWERS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "Tower" }));
const TOWER_OBBY_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerObby" }));
const TOWER_DECORATION_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerDecoration" }));
const TOWER_MECHANICS_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerMechanics" }));
const TOWER_BGM_ZONES_SERVER_STORAGE = new Lazy(() => Make("Folder", { Name: "TowerBackgroundMusicZones" }));

@Service()
export class TowerService {
	private logger = createLogger("TowerService");

	private towers = new Set<Tower>();
	private infoToTower = new Map<TowerInfo, Tower>();
	private nameToTower = new Map<string, Tower>();

	async initTower(instance: Instance) {
		this.logger.trace("Initializing tower", instance.GetFullName());

		const info = NAME_TO_TOWER.get(instance.Name);
		if (!info) {
			this.logger.warn(
				"Cannot initialize tower",
				instance.GetFullName(),
				"because no matching TowerInfo in shared/areas.ts",
			);
			return;
		}

		const maybeInstance = castToTowerInstance(instance);
		if (!maybeInstance.some) {
			this.logger.warn(
				"Cannot initialize tower",
				instance.GetFullName(),
				"because invalid instance tree:",
				maybeInstance.reason,
			);

			return;
		}

		const towerInstance = maybeInstance.value;

		for (const zone of towerInstance.BackgroundMusicZones.GetDescendants()) {
			if (BackgroundMusicZoneInstance(zone)) {
				zone.Sound.SetAttribute("OriginalVolume", zone.Sound.Volume);
				const assetToUse = audios[zone.Sound.GetAttribute("UseAudioAsset") as never] as string;
				if (assetToUse) {
					this.logger.trace("Using audio asset", assetToUse, "for", instance.GetFullName());
					zone.Sound.SoundId = assetToUse;
				}
			}
		}

		const tower: Tower = {
			info,
			instance: towerInstance,
			obby: towerInstance.Obby,
			decoration: towerInstance.Decoration,
			mechanics: towerInstance.Mechanics,
			spawn: towerInstance.Spawn,
			bgmZones: towerInstance.BackgroundMusicZones,
		};

		towerInstance.Obby.Parent = TOWER_OBBY_SERVER_STORAGE.getValue();
		towerInstance.Decoration.Parent = TOWER_DECORATION_SERVER_STORAGE.getValue();
		towerInstance.Mechanics.Parent = TOWER_MECHANICS_SERVER_STORAGE.getValue();
		towerInstance.BackgroundMusicZones.Parent = TOWER_BGM_ZONES_SERVER_STORAGE.getValue();

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
