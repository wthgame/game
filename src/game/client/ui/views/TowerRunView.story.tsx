import { InferVideProps, Slider } from "@rbxts/ui-labs";
import Vide from "@rbxts/vide";
import { AREAS } from "game/shared/areas";
import { TowerRunView } from "./TowerRunView";

const CONTROLS = {
	time: Slider(60, 0, 60 * 60 * 24 * 7),
} as const;

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => (
		<TowerRunView time={controls.time} info={AREAS[0]!.towers![0]!} />
	),
};
