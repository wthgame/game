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

export const DIFFICULTY_TO_COLOR = {
	[TowerDifficulty.Easy]: Color3.fromHSV(104 / 360, 0.5, 0.9),
	[TowerDifficulty.Medium]: Color3.fromHSV(41 / 360, 0.5, 0.9),
	[TowerDifficulty.Hard]: Color3.fromHSV(16 / 360, 0.5, 0.9),
	[TowerDifficulty.Difficult]: Color3.fromHSV(0 / 360, 0.5, 0.9),
	[TowerDifficulty.Challenging]: Color3.fromHSV(334 / 360, 0.5, 0.9),
	[TowerDifficulty.Intense]: Color3.fromHSV(280 / 360, 0.5, 0.9),
	[TowerDifficulty.Remorseless]: Color3.fromHSV(315 / 360, 0.5, 0.9),
	[TowerDifficulty.Insane]: Color3.fromHSV(234 / 360, 0.5, 0.9),
	[TowerDifficulty.Extreme]: Color3.fromRGB(90, 170, 60),
	[TowerDifficulty.Terrifying]: Color3.fromRGB(90, 170, 60),
	[TowerDifficulty.Catastrophic]: Color3.fromRGB(90, 170, 60),
	[TowerDifficulty.Horrific]: Color3.fromRGB(90, 170, 60),
} satisfies Record<TowerDifficulty, Color3>;

export function getFlooredColorOfDifficulty(difficulty: number) {
	return DIFFICULTY_TO_COLOR[math.floor(difficulty) as never] ?? new Color3(1, 1, 1);
}
