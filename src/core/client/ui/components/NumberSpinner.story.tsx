import Vide from "@rbxts/vide";
import { InferVideProps, Slider } from "ui-labs";
import { useRem } from "../rem";
import { fonts } from "../styles";
import { NumberSpinner } from "./NumberSpinner";

const CONTROLS = {
	value: Slider(777, 0, 999, 1),
} as const;

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => {
		useRem();
		return (
			<NumberSpinner
				value={controls.value}
				numDigits={3}
				size={UDim2.fromOffset(200, 75)}
				anchorPoint={new Vector2(0.5, 0.5)}
				position={UDim2.fromScale(0.5, 0.5)}
				font={fonts.serif.regular}
				textColor={new Color3(1, 1, 1)}
			></NumberSpinner>
		);
	},
};
