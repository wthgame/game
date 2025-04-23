import { callMethodOnDependency } from "@rbxts/flamework-meta-utils";
import { AxisAction, StandardAction } from "@rbxts/mechanism";
import { onFlameworkIgnited } from "core/shared/flamework";

export function OnInput(action: StandardAction) {
	return (
		ctor: object,
		_: string,
		descriptor: TypedPropertyDescriptor<(this: unknown, action: StandardAction) => void>,
	) => {
		onFlameworkIgnited(() => action.activated.Connect(() => callMethodOnDependency(ctor, descriptor, action)));
	};
}

export function OnAxisInput(action: AxisAction) {
	return (
		ctor: object,
		_: string,
		descriptor: TypedPropertyDescriptor<(this: unknown, action: AxisAction) => void>,
	) => {
		onFlameworkIgnited(() => action.updated.Connect(() => callMethodOnDependency(ctor, descriptor, action)));
	};
}
