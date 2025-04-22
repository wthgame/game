import { Derivable } from "@rbxts/vide";

export interface BaseProps {
	name?: Derivable<string>;
	zIndex?: Derivable<number>;
	layoutOrder?: Derivable<number>;
}

export interface FlexProps {
	flexMode?: Derivable<Enum.UIFlexMode>;
}

export interface LayoutProps {
	position?: Derivable<UDim2>;
	anchorPoint?: Derivable<Vector2>;
	size?: Derivable<UDim2>;
	automaticSize?: Derivable<Enum.AutomaticSize>;
	sizeConstraint?: Derivable<Enum.SizeConstraint>;
}
