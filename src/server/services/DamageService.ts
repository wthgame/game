import { Service } from "@flamework/core";
import { mechanics } from "server/net";
import { Blink } from "shared/decorators";
import { trace } from "shared/log";

export enum DamageType {
	Normal = 5,
	Heavy = 20,
	Lethal = math.huge,
}

const DEBOUNCE_DURATION_SECONDS = 1 / 20;

@Service()
export class DamageService {
	private debounce = new Set<Player>();

	@Blink(mechanics.damageSelf)
	damageSelf(player: Player, kind: string) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);

		const humanoid = player.Character?.FindFirstChildOfClass("Humanoid");
		if (humanoid) {
			trace("Damaging player", player, "by", kind.lower(), "damage");
			humanoid.TakeDamage(DamageType[kind as "Normal" | "Heavy" | "Lethal"]);
			task.wait(DEBOUNCE_DURATION_SECONDS);
			this.debounce.delete(player);
		}
	}

	@Blink(mechanics.damageSelfVariable)
	damageSelfVariable(player: Player, amount: number) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);

		const humanoid = player.Character?.FindFirstChildOfClass("Humanoid");
		if (humanoid) {
			trace("Damaging player", player, "by", amount, "health");
			humanoid.TakeDamage(amount);
			task.wait(DEBOUNCE_DURATION_SECONDS);
			this.debounce.delete(player);
		}
	}
}
