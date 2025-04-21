import Vide, { effect, Provider, source } from "@rbxts/vide";
import { TriangularButton } from "./TriangularButton";
import { debug, setWTHAsDefaultLogger } from "game/shared/log";
import { ButtonStyle } from "./Button";
import { Choose, InferVideProps } from "@rbxts/ui-labs";
import { currentPalette, palette, PALLETES } from "../palette";
import { StoryThemePreview } from "./StoryThemePreview";
import { px } from "../px";

export = {
	vide: Vide,
	story: () => {
		setWTHAsDefaultLogger();
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
							Padding={() => new UDim(0, px(4))}
						></uilistlayout>
						<TriangularButton
							buttonStyle={() => ButtonStyle.Primary}
							buttonLabel={() => `${clicks()} clicks`}
							onClick={() => clicks(clicks() + 1)}
						/>
						<TriangularButton
							buttonStyle={() => ButtonStyle.Secondary}
							buttonLabel={() => `${clicks()} clicks`}
							onClick={() => clicks(clicks() + 1)}
						/>
					</>
				)}
			/>
		);
	},
};
