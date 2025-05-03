import { context, Derivable, read, source, untrack } from "@rbxts/vide";

/// A set of colours that can be used to theme UI components.
export interface Primary {
	fill: {
		light: Color3;
		mid: Color3;
		dark: Color3;
	};
	stroke: {
		light: Color3;
		mid: Color3;
		dark: Color3;
	};
	text: Color3;
}

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
}

export const WTH_GRAY_HUE = 200 / 360;
export const WTH_GRAY_SATURATION = 0.05;
export const WTH_PRIMARY_HUE = 40 / 360;
export const WTH_PRIMARY_SATURATION = 0.75;

export const PALLETES = {
	dark: {
		name: "Dark",

		text: Color3.fromRGB(214, 214, 214),
		subtext1: Color3.fromRGB(194, 194, 194),
		subtext0: Color3.fromRGB(173, 173, 173),
		overlay2: Color3.fromRGB(153, 153, 153),
		overlay1: Color3.fromRGB(132, 132, 132),
		overlay0: Color3.fromRGB(112, 112, 112),
		surface2: Color3.fromRGB(91, 91, 91),
		surface1: Color3.fromRGB(71, 71, 71),
		surface0: Color3.fromRGB(50, 50, 50),
		base: Color3.fromRGB(30, 30, 30),
		mantle: Color3.fromRGB(24, 24, 24),
		crust: Color3.fromRGB(17, 17, 17),
	},
	light: {
		name: "Light",

		text: Color3.fromRGB(205, 214, 244),
		subtext1: Color3.fromRGB(186, 194, 222),
		subtext0: Color3.fromRGB(166, 173, 200),
		overlay2: Color3.fromRGB(147, 153, 178),
		overlay1: Color3.fromRGB(127, 132, 156),
		overlay0: Color3.fromRGB(108, 112, 134),
		surface2: Color3.fromRGB(88, 91, 112),
		surface1: Color3.fromRGB(69, 71, 90),
		surface0: Color3.fromRGB(49, 50, 68),
		base: Color3.fromRGB(30, 30, 46),
		mantle: Color3.fromRGB(24, 24, 37),
		crust: Color3.fromRGB(17, 17, 27),
	},
} satisfies Record<string, Palette>;

export const paletteValue = source(PALLETES.dark);
export const currentPalette = context<Derivable<Palette>>(untrack(paletteValue));

export function palette<K extends keyof Palette>(key: K) {
	return read(currentPalette())[key];
}
