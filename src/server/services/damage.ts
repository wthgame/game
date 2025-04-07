import { Service } from "@flamework/core";
import { Blink } from "server/decorators";
import { mechanics } from "server/net";
import { trace } from "shared/log";

export enum DamageType {
	Normal = 5,
	Harmful = 20,
	Lethal = 100,
}

const DEBOUNCE_DURATION_SECONDS = 0.05;

@Service()
export class DamageService {
	private debounce = new Set<Player>();

	@Blink(mechanics.damageSelf)
	damageSelf(player: Player, kind: string) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);
		trace("Damaging player", player, "by", kind.lower(), "damage");
		player.Character?.FindFirstChildOfClass("Humanoid")?.TakeDamage(
			DamageType[kind as "Normal" | "Harmful" | "Lethal"],
		);
		task.wait(DEBOUNCE_DURATION_SECONDS);
		this.debounce.delete(player);
	}

	@Blink(mechanics.damageSelfVariable)
	damageSelfVariable(player: Player, amount: number) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);
		trace("Damaging player", player, "by", amount, "health");
		player.Character?.FindFirstChildOfClass("Humanoid")?.TakeDamage(amount);
		task.wait(DEBOUNCE_DURATION_SECONDS);
		this.debounce.delete(player);
	}
}
