import Vide from "@rbxts/vide";
import { AREAS } from "shared/areas";
import { TowerPreview } from "./TowerPreview";

// const CONTROLS = {
// 	progress: Slider(0.5, 0, 1),
// } as const;

export = {
	vide: Vide,
	// controls: CONTROLS,
	story: () => <TowerPreview info={AREAS[0]!.towers![0]!} onRunRequested={() => {}} />,
};
