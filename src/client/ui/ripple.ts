import { effect } from "@rbxts/charm";
import { useMotion } from "@rbxts/pretty-vide-utils";
import type { MotionGoal, TweenOptions } from "@rbxts/ripple";
import type { Source } from "@rbxts/vide";
import { memoize } from "shared/libs/memoize";

export const tween = memoize(
	(
		time: number = 0.1,
		style: Enum.EasingStyle = Enum.EasingStyle.Quart,
		direction?: Enum.EasingDirection,
	): TweenOptions => {
		return {
			time,
			style,
			direction,
		};
	},
);

export function useToggleTween<T extends MotionGoal>(
	toggle: Source<unknown>,
	truthy: T,
	falsy: T,
	tween?: TweenOptions,
): () => T {
	const [out, outMotion] = useMotion(falsy);
	// eslint-disable-next-line roblox-ts/lua-truthiness
	effect(() => outMotion.tween(toggle() ? (truthy as never) : (falsy as never), tween));
	effect(() => print(toggle()));
	return out;
}
