import { callMethodOnDependency } from "@rbxts/flamework-meta-utils";
import { onFlameworkIgnited } from "core/shared/flamework";
import { createLogger } from "core/shared/logger";

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
		on: (callback: (...args: Args) => Returns) => void;
	},
	{ ratelimit, restrictedToDevelopers }: BlinkFunctionProps = DEFAULT_BLINK_FUNCTION_PROPS,
) {
	return (
		ctor: object,
		_: string,
		descriptor: TypedPropertyDescriptor<(this: unknown, ...args: Args) => Returns>,
	) => {
		onFlameworkIgnited(() => callback.on((...args: Args) => callMethodOnDependency(ctor, descriptor, ...args)));
	};
}

const logger = createLogger("LogBenchmark");
export function LogBenchmark<Args extends unknown[] = unknown[]>(
	formatter?: (methodName: string, msElapsed: number, ...args: Args) => string,
) {
	return (
		ctor: object,
		propertyKey: string,
		descriptor: TypedPropertyDescriptor<(this: unknown, ...args: Args) => unknown>,
	) => {
		const object = <Record<string, Callback>>ctor;
		formatter ??= (name, elapsed, ..._) => `Method "${name}" took ${string.format("%.2f", elapsed)} ms to execute.`;
		object[propertyKey] = function (_: unknown, ...args: Args) {
			const startTime = os.clock();
			const result = descriptor.value(_, ...args);
			const endTime = os.clock();
			const elapsed = (endTime - startTime) * 1000;
			logger.info(formatter!(propertyKey, elapsed, ...args));
			return result;
		};
	};
}
