import { InferEnumNames } from "@rbxts/vide";

export interface Palette {
	name: string;

	text: Color3;
	subtext1: Color3;
	subtext0: Color3;
	overlay2: Color3;
	overlay1: Color3;
	overlay0: Color3;
	surface2: Color3;
	surface1: Color3;
	surface0: Color3;
	base: Color3;
	mantle: Color3;
	crust: Color3;

	primaries: {};
}

export interface FontStyles {
	regular: Font;
	bold: Font;
}

function createFontStyles(fontName: InferEnumNames<Enum.Font>): Readonly<FontStyles> {
	return table.freeze({
		regular: Font.fromName(fontName as string, Enum.FontWeight.Regular),
		bold: Font.fromName(fontName as string, Enum.FontWeight.Bold),
	});
}

export const fonts = table.freeze({
	serif: createFontStyles("Merriweather"),
	mono: createFontStyles("RobotoMono"),
});
