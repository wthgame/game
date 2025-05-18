import { Controller, Modding } from "@flamework/core";
import { Players } from "@rbxts/services";

export interface OnPlayerAdded {
	onPlayerAdded(player: Player): void;
}

export interface OnPlayerRemoving {
	onPlayerRemoving(player: Player): void;
}

function callPlayerAdded(listener: OnPlayerAdded, player: Player) {
	listener.onPlayerAdded(player);
}

function callPlayerRemoving(listener: OnPlayerRemoving, player: Player) {
	listener.onPlayerRemoving(player);
}

@Controller()
export class PlayersHookManager {
	private added = new Set<OnPlayerAdded>();
	private removing = new Set<OnPlayerRemoving>();

	onStart(): void {
		Modding.onListenerAdded<OnPlayerAdded>((object) => this.added.add(object));
		Modding.onListenerRemoved<OnPlayerRemoving>((object) => this.removing.delete(object));
		Players.PlayerAdded.Connect((player) => {
			for (const listener of this.added) task.spawn(callPlayerAdded, listener, player);
		});
		Players.PlayerRemoving.Connect((player) => {
			for (const listener of this.removing) task.spawn(callPlayerRemoving, listener, player);
		});
		for (const player of Players.GetPlayers()) {
			for (const listener of this.added) task.spawn(callPlayerAdded, listener, player);
		}
	}
}
