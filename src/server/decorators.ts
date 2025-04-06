import { callMethodOnDependency } from "@rbxts/flamework-meta-utils";
import { onFlameworkIgnited } from "shared/flamework";

export interface BlinkFunctionProps {
	ratelimit?: unknown;
	restrictedToDevelopers?: boolean;
}

const DEFAULT_BLINK_FUNCTION_PROPS: BlinkFunctionProps = {
	ratelimit: false,
	restrictedToDevelopers: false,
};

/** @metadata reflect identifier flamework:parameters */
export function Blink<Args extends unknown[] = unknown[], Returns = unknown>(
	callback: {
		on: (callback: (player: Player, ...args: Args) => Returns) => void;
	},
	{ ratelimit, restrictedToDevelopers }: BlinkFunctionProps = DEFAULT_BLINK_FUNCTION_PROPS,
) {
	return (
		ctor: object,
		_: string,
		descriptor: TypedPropertyDescriptor<(this: unknown, player: Player, ...args: Args) => Returns>,
	) => {
		onFlameworkIgnited(() =>
			callback.on((player: Player, ...args: Args) => callMethodOnDependency(ctor, descriptor, player, ...args)),
		);
	};
}
