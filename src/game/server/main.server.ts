import { Flamework } from "@flamework/core";
import { flameworkIgnited, panic } from "game/shared/flamework";
import { info, setWTHAsDefaultLogger } from "game/shared/log";

try {
	setWTHAsDefaultLogger();
	Flamework.addPaths("src/game/server/services");
	Flamework.addPaths("src/shared/server/services");
	Flamework.ignite();
	flameworkIgnited();
	info("Server ignited!");
} catch (e) {
	panic(`Failed to ignite server; ${e}`);
}
