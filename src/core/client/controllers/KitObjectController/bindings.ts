import { createLogger } from "core/shared/logger";

const logger = createLogger("KitObjectController.bindings");

const bindings = new Map<unknown, (...args: unknown[]) => unknown>();

export function addKitBinding(key: unknown, callback: (...args: unknown[]) => unknown) {
	logger.trace(`Adding mechanic binding: ${key}`);
	bindings.set(key, callback);
}

export function callKitBinding(key: unknown, ...args: unknown[]) {
	logger.trace(`Calling mechanic binding: ${key}`);
	const callback = bindings.get(key);
	if (callback) {
		callback(...args);
	}
}
