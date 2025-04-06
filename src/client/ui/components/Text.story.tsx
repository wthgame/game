// import Fusion, { peek } from "@rbxts/fusion";
// import { choose, fusionStory } from "client/ui/uilabs";
import { Text, TextStyle } from "client/ui/components/Text";
// import { debug, setWTHAsDefaultLogger } from "shared/log";
import { Choose, CreateVideStory } from "@rbxts/ui-labs";
import Vide, { effect, read } from "@rbxts/vide";
import { debug, setWTHAsDefaultLogger } from "shared/log";

const STORY_TEXT_STYLES: Array<[label: string, value: TextStyle]> = [
	["Title", TextStyle.Title],
	["Subtitle", TextStyle.Subtitle],
	["Text", TextStyle.Text],
	["Label", TextStyle.Label],
	["ButtonPrimaryLabel", TextStyle.ButtonPrimaryLabel],
];

const MAP_STORY_TEXT_STYLES = new Map(STORY_TEXT_STYLES);

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
			textStyle: Choose(
				STORY_TEXT_STYLES.map(([v]) => v),
				3,
			),
			textAlignX: Choose(["left", "center", "right"], 1),
			textAlignY: Choose(["top", "center", "bottom"], 1),
		},
	},
	({ controls }) => {
		setWTHAsDefaultLogger();
		return (
			<Text
				text={controls.text}
				textStyle={() => MAP_STORY_TEXT_STYLES.get(read(controls.textStyle))!}
				textAlignX={controls.textAlignX as never}
				textAlignY={controls.textAlignY as never}
				anchorPoint={new Vector2(0.5, 0.5)}
				position={UDim2.fromScale(0.5, 0.5)}
			/>
		);
	},
);
