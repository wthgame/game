import Vide, { effect, source } from "@rbxts/vide";
import { debug, setWTHAsDefaultLogger } from "core/shared/log";
import { rem, useRem } from "../rem";
import { PrimaryTriangularButton } from "./PrimaryTriangularButton";
import { StoryThemePreview } from "./StoryThemePreview";

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
						<PrimaryTriangularButton
							buttonLabel={() => `${clicks()} clicks`}
							onClick={() => clicks(clicks() + 1)}
						/>
					</>
				)}
			/>
		);
	},
};
