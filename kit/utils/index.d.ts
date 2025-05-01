import { Trove } from "@rbxts/trove";

declare namespace KitUtils {
	export function connectActivation<T extends Instance>(
		outerTrove: Trove,
		connectTo: T,
		onActivated: (outerTrove: Trove, instance: T, activationTrove: Trove) => void,
	): void;
}

export = KitUtils;
export as namespace KitUtils;
