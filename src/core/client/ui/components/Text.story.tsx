// import Fusion, { peek } from "@rbxts/fusion";
// import { choose, fusionStory } from "client/ui/uilabs";
import { Text } from "core/client/ui/components/Text";
// import { debug, setWTHAsDefaultLogger } from "shared/log";
import { Choose, CreateVideStory, RGBA, Slider } from "@rbxts/ui-labs";
import Vide from "@rbxts/vide";
import { sans } from "../fonts";
import { rem, useRem } from "../rem";

const TOCAV_WIKI_PAGE =
	"Tower of Complexity and Volatility (ToCaV) is a Terrifying difficulty, ascension-based " +
	"Tower located in Zone 10. It was made by Miantoz1980, ImNotFireMan123 and " +
	"ConfirmedIlluminatix. This tower is known for its time manipulation gimmicks. It can be " +
	"played in its own place here.";

export = CreateVideStory(
	{
		vide: Vide,
		controls: {
			text: TOCAV_WIKI_PAGE,
			textRgba: RGBA(new Color3(1, 1, 1), 0),
			textSizeRem: Slider(1, 0.5, 3, 0.5),
			textAlignX: Choose(["left", "center", "right"], 1),
			textAlignY: Choose(["top", "center", "bottom"], 1),
		},
	},
	({ controls }) => {
		useRem();
		return (
			<Text
				text={controls.text}
				textColor={() => controls.textRgba().Color}
				visibility={() => controls.textRgba().Transparency}
				textSize={() => rem(controls.textSizeRem())}
				font={sans()}
				textAlignX={controls.textAlignX as never}
				textAlignY={controls.textAlignY as never}
				anchorPoint={new Vector2(0.5, 0.5)}
				position={UDim2.fromScale(0.5, 0.5)}
			/>
		);
	},
);
