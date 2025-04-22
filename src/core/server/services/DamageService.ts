import { Service } from "@flamework/core";
import { damageSelf, damageSelfVariable } from "core/server/net";
import { Blink } from "core/shared/decorators";
import { trace } from "core/shared/log";

export enum DamageType {
	Normal = 10,
	Heavy = 20,
	Super = 40,
	Lethal = math.huge,
}

const DEBOUNCE_DURATION_SECONDS = 0.5;

@Service()
export class DamageService {
	private debounce = new Set<Player>();

	@Blink(damageSelf)
	damageSelf(player: Player, kind: string) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);

		const humanoid = player.Character?.FindFirstChildOfClass("Humanoid");
		if (humanoid) {
			trace("Damaging player", player, "by", kind.lower(), "damage");
			const damage = DamageType[kind as "Normal" | "Heavy" | "Super" | "Lethal"];
			const difference = humanoid.MaxHealth - humanoid.Health;
			humanoid.TakeDamage(math.max(-difference, damage));
			task.wait(DEBOUNCE_DURATION_SECONDS);
			this.debounce.delete(player);
		}
	}

	@Blink(damageSelfVariable)
	damageSelfVariable(player: Player, amount: number) {
		if (this.debounce.has(player)) return;
		this.debounce.add(player);

		const humanoid = player.Character?.FindFirstChildOfClass("Humanoid");
		if (humanoid) {
			trace("Damaging player", player, "by", amount, "health");
			const difference = humanoid.MaxHealth - humanoid.Health;
			humanoid.TakeDamage(math.max(-difference, math.abs(amount)));
			task.wait(DEBOUNCE_DURATION_SECONDS);
			this.debounce.delete(player);
		}
	}
}
