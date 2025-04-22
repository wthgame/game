import Event from "@rbxts/libopen-event";
import { Players, RunService } from "@rbxts/services";
import { err } from "./log";

export const [onFlameworkIgnited, flameworkIgnited] = Event<[]>();
export const [onFlameworkExtinguished, flameworkExtinguish] = Event<[]>();

export function panic(message: string): never {
	const isClient = RunService.IsClient();

	const fmtMessage =
		`The ${isClient ? "client" : "server"} panicked: ${message}.` +
		"\nThis is a bug in Welcome to Hell." +
		"\nPlease file a bug report in the community server." +
		"\nWelcome to Hell will make a best effort recovery.";

	err(`Panicked: ${message}`);
	pcall(flameworkExtinguish);

	if (isClient) {
		Players.LocalPlayer.Kick(fmtMessage);
	} else {
		for (const player of Players.GetPlayers()) player.Kick(fmtMessage);
		Players.PlayerAdded.Connect((player) => player.Kick(fmtMessage));
	}

	throw message;
}
