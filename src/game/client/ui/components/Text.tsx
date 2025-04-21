import Vide, { Derivable, read, Source } from "@rbxts/vide";
import { Padding, PaddingProps } from "game/client/ui/components/Padding";
import { sans } from "game/client/ui/fonts";
import { Palette, palette } from "game/client/ui/palette";
import { BaseProps, LayoutProps } from "game/client/ui/types";

export enum TextStyle {
	Title,
	Subtitle,
	Text,
	Label,
	ButtonPrimaryLabel,
	ButtonSecondaryLabel,
}

export type TextAlignX = "left" | "center" | "right";
export type TextAlignY = "top" | "center" | "bottom";

export interface TextProps extends LayoutProps, BaseProps, PaddingProps {
	text: Derivable<string>;
	textStyle: Derivable<TextStyle>;
	textWrapped?: Derivable<boolean>;
	textAlignX?: Derivable<TextAlignX>;
	textAlignY?: Derivable<TextAlignY>;
	rich?: Derivable<boolean>;
	// TODO: reimplement
	outTextBounds?: Source<Vector2>;
}

// TODO: move these values to palette
export const TEXT_STYLE_PALLETE = table.freeze({
	[TextStyle.Title]: "fgLight",
	[TextStyle.Subtitle]: "fgDark",
	[TextStyle.Text]: "fg",
	[TextStyle.Label]: "fgDarker",
	[TextStyle.ButtonPrimaryLabel]: "fgDarkest",
	[TextStyle.ButtonSecondaryLabel]: "fgLight",
} satisfies Record<TextStyle, keyof Palette>);

export const TEXT_STYLE_SIZES = table.freeze({
	[TextStyle.Title]: 24,
	[TextStyle.Subtitle]: 18,
	[TextStyle.Text]: 16,
	[TextStyle.Label]: 12,
	[TextStyle.ButtonPrimaryLabel]: 16,
	[TextStyle.ButtonSecondaryLabel]: 16,
} satisfies Record<TextStyle, number>);

export const TEXT_STYLE_FONTS = table.freeze({
	[TextStyle.Title]: sans(Enum.FontWeight.Bold),
	[TextStyle.Subtitle]: sans(Enum.FontWeight.SemiBold),
	[TextStyle.Text]: sans(),
	[TextStyle.Label]: sans(Enum.FontWeight.Regular, Enum.FontStyle.Italic),
	[TextStyle.ButtonPrimaryLabel]: sans(Enum.FontWeight.Bold),
	[TextStyle.ButtonSecondaryLabel]: sans(Enum.FontWeight.Bold),
} satisfies Record<TextStyle, Font>);

export function Text({
	position,
	anchorPoint,
	size,
	automaticSize = Enum.AutomaticSize.XY,

	name,
	zIndex,
	layoutOrder,

	padding,
	paddingX,
	paddingY,
	paddingLeft,
	paddingRight,
	paddingTop,
	paddingBottom,

	text,
	textStyle,
	textWrapped = true,
	textAlignX = "left",
	textAlignY = "top",
	rich = true,
	outTextBounds,
}: TextProps) {
	const hasPadding =
		(padding ?? paddingX ?? paddingY ?? paddingLeft ?? paddingRight ?? paddingTop ?? paddingBottom) !== undefined;
	return (
		<textlabel
			Position={position}
			AnchorPoint={anchorPoint}
			Size={size}
			AutomaticSize={automaticSize}
			Name={name ?? text}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			BackgroundTransparency={1}
			FontFace={() => TEXT_STYLE_FONTS[read(textStyle)]}
			Text={text}
			TextColor3={() => palette(TEXT_STYLE_PALLETE[read(textStyle)])}
			TextSize={() => TEXT_STYLE_SIZES[read(textStyle)]}
			TextWrapped={textWrapped}
			TextXAlignment={() => {
				switch (read(textAlignX)) {
					case "left":
						return Enum.TextXAlignment.Left;
					case "center":
						return Enum.TextXAlignment.Center;
					case "right":
						return Enum.TextXAlignment.Right;
					default:
						throw `unknown Text.textAlignX: ${read(textAlignX)}`;
				}
			}}
			TextYAlignment={() => {
				switch (read(textAlignY)) {
					case "top":
						return Enum.TextYAlignment.Top;
					case "center":
						return Enum.TextYAlignment.Center;
					case "bottom":
						return Enum.TextYAlignment.Bottom;
					default:
						throw `unknown Text.textAlignY: ${read(textAlignY)}`;
				}
			}}
			RichText={rich}
			// Out:TextBounds={outTextBounds}
		>
			{hasPadding ? (
				<Padding
					// scope={scope}
					padding={padding}
					paddingX={paddingX}
					paddingY={paddingY}
					paddingLeft={paddingLeft}
					paddingRight={paddingRight}
					paddingTop={paddingTop}
					paddingBottom={paddingBottom}
				/>
			) : (
				[]
			)}
		</textlabel>
	);
}
