import Vide from "@rbxts/vide";
import { useRem } from "core/client/ui/rem";
import { setWTHAsDefaultLogger } from "core/shared/log";
import { AREAS } from "game/shared/areas";
import { InferVideProps, Slider } from "ui-labs";
import { RunInfo } from "./RunInfo";

const CONTROLS = {
	elapsedTime: Slider(3600 + 60 * 30, 0, 3600 * 24),
	previewTower: true,
} as const;

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => {
		setWTHAsDefaultLogger();
		useRem();
		return (
			<RunInfo
				elaspedTime={controls.elapsedTime}
				towerInfo={() => (controls.previewTower() ? AREAS[0]!.towers![1]! : undefined)}
			/>
		);
	},
};
