import { Flamework } from "@flamework/core";
import { flameworkIgnited, panic } from "core/shared/flamework";
import { info, setWTHAsDefaultLogger } from "core/shared/log";

try {
	setWTHAsDefaultLogger();
	Flamework.addPaths("src/game/server/services");
	Flamework.addPaths("src/core/server/services");
	Flamework.ignite();
	flameworkIgnited();
	info("Server ignited!");
} catch (e) {
	panic(`Failed to ignite server; ${e}`);
}
