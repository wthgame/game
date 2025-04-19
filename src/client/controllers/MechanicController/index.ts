import { Controller, OnStart } from "@flamework/core";
import { Trove } from "@rbxts/trove";

export interface Mechanic {
	type: "Mechanic";
	name: string;
	persistent: boolean;
	init: (self: Mechanic, wth: WTH) => void;
}

export class MechanicTag {}

export class WTH {}

@Controller()
export class MechanicController implements OnStart {
	onStart(): void {}

	tryInitModule(instance: Instance) {}

	tryInitMechanic(instance: Instance) {}

	loadMechanicsFromParent(trove: Trove, parent: Instance) {}
}
