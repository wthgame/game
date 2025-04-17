import { UserId } from "./constants/userids";

export enum TowerType {
	Monument,
	Tower,
}

export enum TowerDifficulty {
	Easy = 1,
	Medium = 2,
	Hard = 3,
	Difficult = 4,
	Challenging = 5,
	Intense = 6,
	Remorseless = 7,
	Insane = 8,
	Extreme = 9,
	Terrifying = 10,
	Catastrophic = 11,
	Horrific = 12,
}

export enum TowerDifficultyIncrement {
	Bottom = 0,
	Baseline = 0.1,
	Low = 0.25,
	LowMid = 0.375,
	Mid = 0.5,
	MidHigh = 0.625,
	High = 0.75,
	Peak = 0.9,
	Skyline = 0.95,
}

export interface TowerInfo {
	name: string;
	title: string;
	type: TowerType;
	difficulty: number;
	abbreviate?: boolean;
	creatorUserIds: number[];
}

export interface TowerInstance extends Instance {
	Mechanics: Instance;
	Obby: Instance;
	Details: Instance;
	Frame: Instance;
	Spawn: BasePart;
}

export interface AreaInfo {
	name: string;
	actNumber?: number;
	title: string;

	playerRequires?: [];

	towers?: TowerInfo[];
}

export interface AreaInstance extends Instance {
	Mechanics: Instance;
	Towers?: Instance;
	Lobby: Instance;
	Spawn: BasePart;
}

// ---

export const AREAS: AreaInfo[] = [
	{
		name: "A1MoltenHeart",
		actNumber: 1,
		title: "Molten Heart",
		towers: [
			{
				name: "ToPaS",
				title: "Tower of Push and Shove",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Easy + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
			{
				name: "ToSH",
				title: "Tower of Sky High",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Hard + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
			{
				name: "ToOO",
				title: "Tower of Omelette Overcast",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Challenging + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.thefloodescaper11],
			},
			{
				name: "CT",
				title: "Cooler's Tower",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Intense + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.randomcoolers],
			},
			{
				name: "GoCT",
				title: "Gibbal and Crazy's Tower",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Remorseless + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.Talik_Roy, UserId.The_CrazyNUGGY001],
			},
			{
				name: "ToPCTS",
				title: "Tower of Push Comes To Shove",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Insane + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.Miantoz1980],
			},
			{
				name: "MoDV",
				title: "Monument of Death Valley",
				type: TowerType.Monument,
				difficulty: TowerDifficulty.Remorseless + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
];

export const TOWERS = new Set<TowerInfo>();
export const AREA_NAMES = new Set<string>();
export const TOWER_NAMES = new Set<string>();
export const NAME_TO_AREA = new Map<string, AreaInfo>();
export const NAME_TO_TOWER = new Map<string, TowerInfo>();

for (const area of AREAS) {
	AREA_NAMES.add(area.name);
	NAME_TO_AREA.set(area.name, area);

	if (area.towers) {
		for (const tower of area.towers) {
			TOWERS.add(tower);
			TOWER_NAMES.add(tower.name);
			NAME_TO_TOWER.set(tower.name, tower);
		}
	}
}
