import ty from "@rbxts/libopen-ty";
import { context, Derivable, read, source, untrack } from "@rbxts/vide";

const tyColor3 = ty.Typeof("Color3");
const Palette = ty
	.Struct(
		{ exhaustive: true },
		{
			name: ty.String,

			text: tyColor3,
			subtext1: tyColor3,
			subtext0: tyColor3,
			overlay2: tyColor3,
			overlay1: tyColor3,
			overlay0: tyColor3,
			surface2: tyColor3,
			surface1: tyColor3,
			surface0: tyColor3,
			base: tyColor3,
			mantle: tyColor3,
			crust: tyColor3,

			platinumText: tyColor3,
			platinumHover: tyColor3,
			platinumBase: tyColor3,
		},
	)
	.Nicknamed("Palette");

export interface Palette extends ty.Static<typeof Palette> {}

function createPalette(palette: { [K in keyof Palette]: Palette[K] | keyof Palette }): Readonly<Palette> {
	palette = table.clone(palette);
	for (const [key, value] of pairs(palette)) {
		const referenced = palette[value as never];
		if (referenced) palette[key] = referenced;
	}
	return table.freeze(Palette.CastOrError(palette));
}

const WTH_BASE_HUE = 30 / 360;
const WTH_BASE_CHROMA = 1;

const WTH_PLATINUM_HUE = 330 / 360;
const WTH_PLATINUM_CHROMA = 1 / 12;

export const PALLETES = table.freeze({
	dark: createPalette({
		name: "Dark",

		text: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA / 2, 1),
		subtext1: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA / 2, 0.85),
		subtext0: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA / 2, 0.8),
		overlay2: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.65),
		overlay1: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.55),
		overlay0: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.5),
		surface2: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.35),
		surface1: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.3),
		surface0: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.25),
		base: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.15),
		mantle: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.1),
		crust: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.05),

		platinumBase: Color3.fromHSV(WTH_PLATINUM_HUE, WTH_PLATINUM_CHROMA, 0.75),
		platinumHover: Color3.fromHSV(WTH_PLATINUM_HUE, WTH_PLATINUM_CHROMA, 0.8),
		platinumText: Color3.fromHSV(WTH_PLATINUM_HUE, WTH_PLATINUM_CHROMA, 0.3),
	}),
	light: createPalette({
		name: "Light",

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

		platinumBase: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.75),
		platinumHover: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.8),
		platinumText: Color3.fromHSV(WTH_BASE_HUE, WTH_BASE_CHROMA, 0.9),
	}),
} satisfies Record<string, Readonly<Palette>>);

export const paletteValue = source(PALLETES.dark);
export const currentPalette = context<Derivable<Palette>>(untrack(paletteValue));

export function palette<K extends keyof Palette>(key: K) {
	return read(currentPalette())[key];
}
