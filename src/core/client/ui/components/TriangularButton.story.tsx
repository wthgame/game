import Vide, { effect, source } from "@rbxts/vide";
import { debug, setWTHAsDefaultLogger } from "core/shared/log";
import { px } from "../px";
import { ButtonStyle } from "./Button";
import { StoryThemePreview } from "./StoryThemePreview";
import { TriangularButton } from "./TriangularButton";

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
