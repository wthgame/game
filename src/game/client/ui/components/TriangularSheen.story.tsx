import Vide from "@rbxts/vide";
import { InferVideProps, RGBA, Slider } from "ui-labs";
import { TriangularSheen } from "./TriangularSheen";

const CONTROLS = {
	visibility: Slider(0, 0, 1),
	radiusPx: Slider(12, 4, 32),
} as const;

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => (
		<TriangularSheen
			visibility={controls.visibility}
			size={UDim2.fromScale(0.5, 0.5)}
			position={UDim2.fromScale(0.5, 0.5)}
			anchorPoint={new Vector2(0.5, 0.5)}
			radiusPx={controls.radiusPx}
		/>
	),
};
