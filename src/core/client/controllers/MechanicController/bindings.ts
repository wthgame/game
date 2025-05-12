import { createLogger } from "core/shared/logger";

const logger = createLogger("MechanicController.bindings");

const bindings = new Map<unknown, (...args: unknown[]) => unknown>();

export function addMechanicBinding(key: unknown, callback: (...args: unknown[]) => unknown) {
	logger.trace(`Adding mechanic binding: ${key}`);
	bindings.set(key, callback);
}

export function callMechanicBinding(key: unknown, ...args: unknown[]) {
	logger.trace(`Calling mechanic binding: ${key}`);
	const callback = bindings.get(key);
	if (callback) {
		callback(...args);
	}
}
