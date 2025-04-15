import ty from "@rbxts/libopen-ty";

export type TowerRunType = "Standard" | "Practice";

export const TowerRunType = ty
	.Just("Standard")
	.Or(ty.Just("Practice"))
	.Nicknamed("TowerRunType")
	.Retype<TowerRunType>();

export interface StartTowerRun {
	towerType: TowerRunType;
	towerName: string;
}

export const StartTowerRun = ty
	.Struct(
		{ exhaustive: true },
		{
			towerType: TowerRunType,
			towerName: ty.String,
		},
	)
	.Nicknamed("StartTowerRun")
	.Retype<StartTowerRun>();

export interface StartTowerRunResult {
	instance: Instance;
	mechanics: Instance;
}
