import { Derivable, Node, PropsWithChildren } from "@rbxts/vide";
import { Palette } from "../palette";
import { TextStyle } from "./Text";
import { BaseProps, LayoutProps } from "../types";
import { PaddingProps } from "./Padding";

export enum ButtonStyle {
	Primary,
	Secondary,
}

export interface ButtonProps extends BaseProps, LayoutProps, PaddingProps, PropsWithChildren {
	buttonStyle: Derivable<ButtonStyle>;
	buttonLabel?: Derivable<string>;
	buttonIcon?: Derivable<Node>;
	onClick?: () => void;
	visibility?: Derivable<number>;
	disabled?: Derivable<boolean>;
}

// TODO: holy shit i need to work on better themes :sob:
export const BUTTON_STYLE_TEXT_STYLE = table.freeze({
	[ButtonStyle.Primary]: TextStyle.ButtonPrimaryLabel,
	[ButtonStyle.Secondary]: TextStyle.ButtonSecondaryLabel,
} satisfies Record<ButtonStyle, TextStyle>);

export const BUTTON_STYLE_BG_PALLETE = table.freeze({
	[ButtonStyle.Primary]: "fgLight",
	[ButtonStyle.Secondary]: "bgLight",
} satisfies Record<ButtonStyle, keyof Palette>);

export const BUTTON_STYLE_BG_HOVER_PALLETE = table.freeze({
	[ButtonStyle.Primary]: "fgLighter",
	[ButtonStyle.Secondary]: "bgLighter",
} satisfies Record<ButtonStyle, keyof Palette>);

export const BUTTON_STYLE_BG_ACTIVE_PALLETE = table.freeze({
	[ButtonStyle.Primary]: "fg",
	[ButtonStyle.Secondary]: "bg",
} satisfies Record<ButtonStyle, keyof Palette>);

export const BUTTON_STYLE_RIPPLE_PALLETE = table.freeze({
	[ButtonStyle.Primary]: "bg",
	[ButtonStyle.Secondary]: "fgLightest",
} satisfies Record<ButtonStyle, keyof Palette>);

export const BUTTON_STYLE_BORDER_PALLETE = table.freeze({
	[ButtonStyle.Primary]: "fgDark",
	[ButtonStyle.Secondary]: "bgDark",
} satisfies Record<ButtonStyle, keyof Palette>);
