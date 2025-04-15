import { trace } from "shared/log";

const bindings = new Map<unknown, (...args: unknown[]) => unknown>();

export function addMechanicBinding(key: unknown, callback: (...args: unknown[]) => unknown) {
	trace(`Adding mechanic binding: ${key}`);
	bindings.set(key, callback);
}

export function callMechanicBinding(key: unknown, ...args: unknown[]) {
	trace(`Calling mechanic binding: ${key}`);
	const callback = bindings.get(key);
	if (callback) {
		callback(...args);
	}
}
