import Vide, { effect, source } from "@rbxts/vide";
import { createLogger } from "core/shared/logger";
import { rem, useRem } from "../rem";
import { fonts, TextSize } from "../styles";
import { StoryThemePreview } from "./StoryThemePreview";
import { PlatinumTriangularButton, PrimaryTriangularButton } from "./TriangularButton";

export = {
	vide: Vide,
	story: () => {
		useRem();

		const logger = createLogger("TriangularButton.story");
		const clicks = source(0);
		effect(() => logger.debug(`Clicked ${clicks()} times`));

		return (
			<StoryThemePreview
				render={() => (
					<>
						<uilistlayout
							HorizontalAlignment="Center"
							VerticalAlignment="Center"
							FillDirection="Vertical"
							Padding={() => new UDim(0, rem(0.5))}
						></uilistlayout>
						<PrimaryTriangularButton
							labelFont={fonts.serif.regular}
							labelSize={() => rem(TextSize.Medium)}
							buttonLabel={() => `${clicks()} clicks`}
							onClick={() => clicks(clicks() + 1)}
						/>
						<PlatinumTriangularButton
							labelFont={fonts.serif.regular}
							labelSize={() => rem(TextSize.Medium)}
							buttonLabel={() => `${clicks()} clicks`}
							onClick={() => clicks(clicks() + 1)}
						/>
					</>
				)}
			/>
		);
	},
};
