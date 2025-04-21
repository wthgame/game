import { UserId } from "./constants/userids";

export enum TowerType {
	Monument,
	Tower,
	Reflection,
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
	doNotAbbreviate?: true;
	hidden?: boolean;
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
		name: "KitDevelopment",
		title: "Welcome To Hell Kit Development",
		towers: [
			{
				name: "ET",
				title: "Example Tower",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Easy + TowerDifficultyIncrement.Bottom,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
	{
		name: "A1MoltenHeart",
		actNumber: 1,
		title: "Molten Heart",
		towers: [
			{
				name: "Prologue",
				title: "Prologue",
				doNotAbbreviate: true,
				hidden: true,
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Easy + TowerDifficultyIncrement.Bottom,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
			{
				name: "ToPaS",
				title: "Tower of Push and Shove",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Easy + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
			{
				name: "ToSH",
				title: "Tower of Turbulance",
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
			{
				name: "A1R",
				title: "Molten Heart's Reflection",
				doNotAbbreviate: true,
				hidden: true,
				type: TowerType.Reflection,
				difficulty: TowerDifficulty.Insane + TowerDifficultyIncrement.Mid,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
	{
		name: "A2FeveredEyes",
		actNumber: 2,
		title: "Fevered Eyes",
		towers: [],
	},
	{
		name: "A3OhNoItsASeriousRobloxGame",
		actNumber: 3,
		title: "Oh No, It's a Serious Roblox Game",
		towers: [
			{
				name: "MoBH",
				title: "Monument of Bleeding Heart",
				type: TowerType.Monument,
				hidden: true,
				difficulty: TowerDifficulty.Challenging + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
	{
		name: "A4BrokenDreams",
		actNumber: 4,
		title: "Broken Dreams",
		towers: [],
	},
	{
		name: "A5RunningInSpirals",
		actNumber: 5,
		title: "Running in Spirals",
		towers: [],
	},
	{
		name: "A6WhereTheHeavensWeptFire",
		actNumber: 6,
		title: "Where the Heavens Wept Fire",
		towers: [
			{
				name: "MoFLS",
				title: "Monument of Forever Luv Sic",
				type: TowerType.Monument,
				hidden: true,
				difficulty: TowerDifficulty.Intense + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
	{
		name: "A7NoReturn",
		actNumber: 7,
		title: "No Return",
		towers: [],
	},
	{
		name: "A8YouBastard",
		actNumber: 8,
		title: "You Bastard",
		towers: [],
	},
	{
		name: "A9BreakingPoint",
		actNumber: 9,
		title: "Breaking Point",
		towers: [
			{
				name: "MoTP",
				title: "Monument of Take Pilot",
				type: TowerType.Monument,
				hidden: true,
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
