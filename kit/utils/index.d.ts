import { Trove } from "@rbxts/trove";

// NOTE: not doing full types, this is solely so activation code between the kit
// and the controllers stay the same
declare namespace KitUtils {
	export namespace prelude {
		export function connectActivation<T extends Instance>(
			outerTrove: Trove,
			connectTo: T,
			onActivated: (outerTrove: Trove, instance: T, activationTrove: Trove) => void,
		): void;
	}
}

export = KitUtils;
export as namespace KitUtils;
