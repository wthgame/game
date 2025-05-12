import { effect } from "@rbxts/charm";
import Vide, { source } from "@rbxts/vide";
import { createLogger } from "core/shared/logger";
import { InferVideProps } from "ui-labs";
import { useRem } from "../rem";
import { Toggle } from "./Toggle";

const CONTROLS = {
	toggled: true,
};

export = {
	vide: Vide,
	controls: CONTROLS,
	story: ({ controls }: InferVideProps<typeof CONTROLS>) => {
		useRem();

		const logger = createLogger("TriangularButton.story");
		const toggled = source(controls.toggled());
		effect(() => {
			toggled(controls.toggled());
		});

		effect(() => {
			logger.trace("Toggled:", toggled());
		});

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
