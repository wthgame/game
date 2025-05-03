import Vide, { effect, source } from "@rbxts/vide";
import { debug, setWTHAsDefaultLogger } from "core/shared/log";
import { palette } from "../palette";
import { rem, useRem } from "../rem";
import { fonts, TextSize } from "../styles";
import { StoryThemePreview } from "./StoryThemePreview";
import { TriangularButton } from "./TriangularButton";

export = {
	vide: Vide,
	story: () => {
		setWTHAsDefaultLogger();
		useRem();

		const clicks = source(0);
		effect(() => debug(`Clicked ${clicks()} times`));

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
						<TriangularButton
							bgColor={() => palette("platinumBase")}
							bgHoverColor={() => palette("platinumHover")}
							labelColor={() => palette("platinumText")}
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
