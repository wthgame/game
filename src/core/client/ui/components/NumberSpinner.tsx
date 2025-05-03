// Implementation from Fusion 0.1 Obby example
// Adapted to @rbxts/vide for use in Welcome To Hell

import Vide, { Derivable, read, spring } from "@rbxts/vide";
import { BaseProps, LayoutProps } from "../types";
import { TextProps } from "./Text";

export interface NumberSpinnerProps
	extends LayoutProps,
		BaseProps,
		Pick<TextProps, "textColor" | "font" | "visibility"> {
	value: Derivable<number>;
	numDigits: number;
}

const NUMBERS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

function Digits({ textColor, font, visibility }: Pick<NumberSpinnerProps, "textColor" | "font" | "visibility">) {
	const digits = [];
	for (const [index, digit] of pairs(NUMBERS)) {
		digits.push(
			<textlabel
				Name={`Label${index}`}
				Position={UDim2.fromScale(0, index - 1)}
				Size={UDim2.fromScale(1, 1)}
				Text={tostring(digit)}
				TextColor3={textColor}
				TextScaled
				FontFace={font}
				TextTransparency={visibility}
				BackgroundTransparency={1}
			/>,
		);
	}

	return digits;
}

export function NumberSpinner({
	name = "NumberSpinner",

	position,
	anchorPoint,
	automaticSize = Enum.AutomaticSize.X,
	size,

	zIndex,
	layoutOrder,

	textColor,
	font,
	visibility = 0,

	value,
	numDigits,
}: NumberSpinnerProps): Vide.Node {
	const digits = [];
	for (const digitPosition of $range(1, numDigits)) {
		// why is an exponent a ** in typescript :sob:
		const fauxRotation = spring(() => math.floor(read(value) / 10 ** (digitPosition - 1)));
		digits.push(
			<frame
				Name={`Digit${digitPosition}`}
				// Digits are written right to left
				LayoutOrder={-digitPosition}
				Size={UDim2.fromScale(0.5, 1)}
				SizeConstraint="RelativeYY"
				BackgroundTransparency={1}
			>
				<frame
					Name="DigitMover"
					Position={() => UDim2.fromScale(0, -(fauxRotation() % 10))}
					Size={UDim2.fromScale(1, 1)}
					BackgroundTransparency={1}
				>
					<Digits textColor={textColor} font={font} visibility={visibility} />
				</frame>
			</frame>,
		);
	}
	return (
		<frame
			Name={name}
			Position={position}
			AnchorPoint={anchorPoint}
			AutomaticSize={automaticSize}
			Size={size}
			ZIndex={zIndex}
			LayoutOrder={layoutOrder}
			BackgroundTransparency={1}
			ClipsDescendants
		>
			<uilistlayout
				SortOrder="LayoutOrder"
				FillDirection="Horizontal"
				HorizontalAlignment="Center"
				VerticalAlignment="Center"
			/>
			{digits}
		</frame>
	);
}
