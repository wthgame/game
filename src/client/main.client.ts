import { Flamework } from "@flamework/core";
import { flameworkIgnited, onFlameworkIgnited, panic } from "shared/flamework";
import { info, setWTHAsDefaultLogger } from "shared/log";

try {
	setWTHAsDefaultLogger();
	Flamework.addPaths("src/client/controllers");
	Flamework.ignite();
	flameworkIgnited();
	info("Client ignited!");
} catch (e) {
	panic(`Failed to ignite client; ${e}`);
}
