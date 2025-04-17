import { effect } from "@rbxts/charm";
import Vide, { source } from "@rbxts/vide";
import { trace } from "shared/log";
import { InferVideProps } from "ui-labs";
import { Toggle } from "./Toggle";

const CONTROLS = {
	toggled: true,
};

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => {
		const toggled = source(controls.toggled());
		effect(() => {
			toggled(controls.toggled());
		});

		effect(() => trace("Toggled:", toggled()));

		return (
			<Toggle
				anchorPoint={new Vector2(0.5, 0.5)}
				position={UDim2.fromScale(0.5, 0.5)}
				toggled={toggled}
				onToggle={() => toggled(!toggled())}
			/>
		);
	},
};
