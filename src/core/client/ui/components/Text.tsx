import Vide, { Derivable, read } from "@rbxts/vide";
import { Padding, PaddingProps } from "core/client/ui/components/Padding";
import { BaseProps, LayoutProps } from "core/client/ui/types";

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
	textColor?: Derivable<Color3>;
	textSize?: Derivable<number>;
	font?: Derivable<Font>;
	textWrapped?: Derivable<boolean>;
	textAlignX?: Derivable<TextAlignX>;
	textAlignY?: Derivable<TextAlignY>;
	rich?: Derivable<boolean>;
	visibility?: Derivable<number>;
	// TODO: reimplement
	// outTextBounds?: Source<Vector2>;
}

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
	textColor,
	textSize,
	font,
	textWrapped = true,
	textAlignX = "left",
	textAlignY = "top",
	rich = true,
	visibility = 0,
	// outTextBounds,
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
			FontFace={font}
			Text={text}
			TextColor3={textColor}
			TextSize={textSize}
			TextWrapped={textWrapped}
			TextTransparency={visibility}
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
