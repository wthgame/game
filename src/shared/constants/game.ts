import { UserId } from "./userids";

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

export interface Tower {
	name: string;
	title: string;
	type: TowerType;
	difficulty: number;
	abbreviate?: boolean;
	creatorUserIds: number[];
}

export interface TowerMechanicsInstance extends Instance {
	Spawn: BasePart;
	Endzones: Instance;
}

export interface TowerInstance extends Instance {
	Mechanics: TowerMechanicsInstance;
	Obby: Instance;
	Design: Instance;
	Frame: Instance;
}

// ---

export interface Act {
	name: string;
	title: string;

	playerRequires?: [];

	towers?: Tower[];
}

export const ACTS: Act[] = [
	{
		name: "Act1",
		title: "Act 1",
		towers: [
			{
				name: "ToPaS",
				title: "Tower of Push and Shove",
				type: TowerType.Tower,
				difficulty: TowerDifficulty.Easy + TowerDifficultyIncrement.Low,
				creatorUserIds: [UserId.ImNotFireMan123],
			},
		],
	},
];

{
	const actNames = new Set();
	const towerNames = new Set();
	for (const act of ACTS) {
		if (!actNames.has(act.name)) throw `Duplicate act name "${act.name}"`;
		actNames.add(act.name);
		if (act.towers) {
			for (const tower of act.towers) {
				if (!towerNames.has(tower.name)) throw `Act "${act.name}" has duplicate tower named "${tower.name}"`;
				towerNames.add(act.name);
			}
		}
	}
}
