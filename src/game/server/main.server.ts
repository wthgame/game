import { Flamework } from "@flamework/core";
import { flameworkIgnited, panic } from "core/shared/flamework";
import { createLogger } from "core/shared/logger";

const logger = createLogger("main");

try {
	Flamework.addPaths("src/game/server/services");
	Flamework.addPaths("src/core/server/services");
	Flamework.ignite();
	flameworkIgnited();
	logger.info("Server ignited!");
} catch (e) {
	panic(`Failed to ignite server; ${e}`);
}
