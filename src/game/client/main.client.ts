import Vide from "@rbxts/vide";
// strict mode runs effects twice
Vide.strict = false;

import { Flamework } from "@flamework/core";
import { flameworkIgnited, panic } from "game/shared/flamework";
import { info, setWTHAsDefaultLogger } from "game/shared/log";

try {
	setWTHAsDefaultLogger();
	Flamework.addPaths("src/game/client/controllers");
	Flamework.addPaths("src/core/client/controllers");
	Flamework.ignite();
	flameworkIgnited();

	info("Client ignited!");
} catch (e) {
	panic(`Failed to ignite client; ${e}`);
}
