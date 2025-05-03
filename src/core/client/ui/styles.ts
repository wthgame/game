import { InferEnumNames } from "@rbxts/vide";

export interface FontStyles {
	regular: Font;
	medium: Font;
	bold: Font;
}

function createFontStyles(fontName: InferEnumNames<Enum.Font>): Readonly<FontStyles> {
	return table.freeze({
		regular: Font.fromName(fontName as string, Enum.FontWeight.Regular),
		medium: Font.fromName(fontName as string, Enum.FontWeight.Medium),
		bold: Font.fromName(fontName as string, Enum.FontWeight.Bold),
	});
}

export const fonts = table.freeze({
	serif: createFontStyles("Merriweather"),
	mono: createFontStyles("RobotoMono"),
});

export enum TextSize {
	Body = 1,
	Small = 0.5,
	Medium = 2,
	Large = 3,
}
