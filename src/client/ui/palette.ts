import Vide, { context, Derivable, read, source, untrack } from "@rbxts/vide";

export interface Palette {
	name: string;

	border: Color3;
	borderLight: Color3;
	borderLighter: Color3;
	borderLightest: Color3;

	bg: Color3;
	bgLight: Color3;
	bgLighter: Color3;
	bgLightest: Color3;
	bgDark: Color3;
	bgDarker: Color3;
	bgDarkest: Color3;

	fg: Color3;
	fgLight: Color3;
	fgLighter: Color3;
	fgLightest: Color3;
	fgDark: Color3;
	fgDarker: Color3;
	fgDarkest: Color3;

	primary: Color3;
	primaryLight: Color3;
	primaryLighter: Color3;
	primaryLightest: Color3;
}

export const WTH_GRAY_HUE = 200 / 360;
export const WTH_GRAY_SATURATION = 0.05;
export const WTH_PRIMARY_HUE = 40 / 360;
export const WTH_PRIMARY_SATURATION = 0.75;

export const PALLETES = {
	dark: {
		name: "Dark",

		border: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.15 - 0.025),
		borderLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.25 - 0.025),
		borderLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.35 - 0.025),
		borderLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.45 - 0.025),
		bg: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.15),
		bgLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.25),
		bgLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.35),
		bgLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.45),
		bgDark: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.1),
		bgDarker: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.05),
		bgDarkest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.025),
		fg: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.8),
		fgLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.875),
		fgLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.95),
		fgLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 1),
		fgDark: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.65),
		fgDarker: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.6),
		fgDarkest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.55),

		primary: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.8),
		primaryLight: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.85),
		primaryLighter: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.9),
		primaryLightest: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.95),
	},
	light: {
		name: "Light",

		border: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.8 - 0.025),
		borderLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.875 - 0.025),
		borderLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.95 - 0.025),
		borderLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 1 - 0.025),
		bg: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.8),
		bgLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.875),
		bgLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.95),
		bgLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 1),
		bgDark: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.1),
		bgDarker: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.05),
		bgDarkest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.025),
		fg: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.15),
		fgLight: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.25),
		fgLighter: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.35),
		fgLightest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.45),
		fgDark: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.15 - 0.025),
		fgDarker: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.25 - 0.025),
		fgDarkest: Color3.fromHSV(WTH_GRAY_HUE, WTH_GRAY_SATURATION, 0.35 - 0.025),

		primary: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.8),
		primaryLight: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.85),
		primaryLighter: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.9),
		primaryLightest: Color3.fromHSV(WTH_PRIMARY_HUE, WTH_PRIMARY_SATURATION, 0.95),
	},
} satisfies Record<string, Palette>;

export const paletteValue = source(PALLETES.dark);
export const currentPalette = context<Derivable<Palette>>(untrack(paletteValue));

export function palette<K extends keyof Palette>(key: K) {
	return read(currentPalette())[key];
}
