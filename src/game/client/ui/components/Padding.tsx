import Vide, { Derivable, read } from "@rbxts/vide";

export interface PaddingProps {
	padding?: Derivable<UDim>;
	paddingX?: Derivable<UDim>;
	paddingY?: Derivable<UDim>;
	paddingLeft?: Derivable<UDim>;
	paddingRight?: Derivable<UDim>;
	paddingTop?: Derivable<UDim>;
	paddingBottom?: Derivable<UDim>;
}

const ZERO_UDIM = new UDim();

export function Padding({
	padding,
	paddingX,
	paddingY,
	paddingLeft,
	paddingRight,
	paddingTop,
	paddingBottom,
}: PaddingProps) {
	return (
		<uipadding
			Name="Padding"
			PaddingLeft={() => read(paddingLeft) ?? read(paddingX) ?? read(padding) ?? ZERO_UDIM}
			PaddingRight={() => read(paddingRight) ?? read(paddingX) ?? read(padding) ?? ZERO_UDIM}
			PaddingTop={() => read(paddingTop) ?? read(paddingY) ?? read(padding) ?? ZERO_UDIM}
			PaddingBottom={() => read(paddingBottom) ?? read(paddingY) ?? read(padding) ?? ZERO_UDIM}
		/>
	);
}
