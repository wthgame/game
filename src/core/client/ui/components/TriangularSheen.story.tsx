import Vide from "@rbxts/vide";
import { InferVideProps, Slider } from "ui-labs";
import { TriangularSheen } from "./TriangularSheen";

const CONTROLS = {
	visibility: Slider(0, 0, 1),
	radius: Slider(0.5, 0, 1),
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
			radius={controls.radius}
		/>
	),
};
