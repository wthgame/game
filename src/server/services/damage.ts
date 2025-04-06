import { Service } from "@flamework/core";
import { Blink } from "server/decorators";
import { mechanics } from "server/net";
import { trace } from "shared/log";

export enum DamageType {
	Normal = 5,
	Harmful = 20,
	Lethal = 100,
}

@Service()
export class DamageService {
	@Blink(mechanics.damageSelf)
	damageSelf(player: Player, kind: string) {
		trace("Damaging player", player, "by", kind.lower(), "damage");
		player.Character?.FindFirstChildOfClass("Humanoid")?.TakeDamage(
			DamageType[kind as "Normal" | "Harmful" | "Lethal"],
		);
	}

	@Blink(mechanics.damageSelfVariable)
	damageSelfVariable(player: Player, amount: number) {
		trace("Damaging player", player, "by", amount, "health");
		player.Character?.FindFirstChildOfClass("Humanoid")?.TakeDamage(amount);
	}
}
