import { Flamework } from "@flamework/core";
import { flameworkIgnited, onFlameworkIgnited, panic } from "shared/flamework";
import { info, setWTHAsDefaultLogger } from "shared/log";

try {
	setWTHAsDefaultLogger();
	Flamework.addPaths("src/server/services");
	Flamework.ignite();
	flameworkIgnited();
	info("Server ignited!");
} catch (e) {
	panic(`Failed to ignite server; ${e}`);
}
