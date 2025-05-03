import { Derivable, Node, PropsWithChildren } from "@rbxts/vide";
import { BaseProps, LayoutProps } from "../types";
import { PaddingProps } from "./Padding";

export interface ButtonProps extends BaseProps, LayoutProps, PaddingProps, PropsWithChildren {
	bgColor?: Derivable<Color3>;
	bgHoverColor?: Derivable<Color3>;
	rippleColor?: Derivable<Color3>;
	labelColor?: Derivable<Color3>;
	labelSize?: Derivable<number>;
	labelFont?: Derivable<Font>;

	buttonLabel?: Derivable<string>;
	buttonIcon?: Derivable<Node>;
	onClick?: () => void;
	visibility?: Derivable<number>;
	disabled?: Derivable<boolean>;
}
