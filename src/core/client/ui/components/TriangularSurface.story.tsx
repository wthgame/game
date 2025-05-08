import Vide from "@rbxts/vide";
import { InferVideProps, RGBA, Slider } from "ui-labs";
import { TriangularSurface } from "./TriangularSurface";

const CONTROLS = {
	rgba: RGBA(new Color3(1, 1, 1), 0),
	radius: Slider(0.5, 0, 1),
} as const;

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => (
		<TriangularSurface
			color={() => controls.rgba().Color}
			visibility={() => controls.rgba().Transparency}
			size={UDim2.fromScale(0.5, 0.5)}
			position={UDim2.fromScale(0.5, 0.5)}
			anchorPoint={new Vector2(0.5, 0.5)}
			radius={controls.radius}
		/>
	),
};
