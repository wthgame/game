import { useViewport } from "@rbxts/pretty-vide-utils";
import { Derivable, read, source } from "@rbxts/vide";

export const DEFAULT_REM = 16;
export const MAXIMUM_REM = math.huge;
export const MINIMUM_REM = 8;
const BASE_RESOLUTION = new Vector2(1920, 1080);
const MAX_ASPECT_RATIO = 19 / 9;

const baseRem = source(1);

export function useRem() {
	useViewport((viewport) => {
		// wide screens should not scale beyond iPhone aspect ratio
		const resolution = new Vector2(math.min(viewport.X, viewport.Y * MAX_ASPECT_RATIO), viewport.Y);
		const scale = resolution.Magnitude / BASE_RESOLUTION.Magnitude;
		const desktop = resolution.X > resolution.Y || scale >= 1;

		// portrait mode should downscale slower than landscape
		const factor = desktop ? scale : math.map(scale, 0, 1, 0.25, 1);

		baseRem(math.clamp(math.round(DEFAULT_REM * factor), MINIMUM_REM, MAXIMUM_REM));
	});
}

export function rem(value: Derivable<number>) {
	return read(value) * baseRem();
}
