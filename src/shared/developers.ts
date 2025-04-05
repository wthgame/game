import Object from "@rbxts/object-utils";
import { RunService } from "@rbxts/services";
import SiftArray from "@rbxts/sift/out/Array";

export enum Developers {
	ImNotFireMan123 = 1275426298,
}

export const DEVELOPER_IDS = <number[]>Object.values(Developers);
export const SET_OF_DEVELOPER_IDS = new Set(DEVELOPER_IDS);

export enum Whitelisted {
	Miantoz1980 = 1275426298,
	// todo i forhot most of the names RIP
	// curse of moving to studio
	Bazooka = 1275426298,
	Creepyrafa_rayitno = 1275426298,
	TheCrazyNuggy = 1275426298,
	NuggetTheCoolOne = 1275426298,
	leoiscool27 = 1275426298,
	talikroy = 1275426298,
	thefloodescaper22 = 1275426298,
}

export const WHITELISTED_IDS: number[] = SiftArray.join(DEVELOPER_IDS, Object.values(Whitelisted));
export const SET_OF_WHITELISTED_IDS = new Set(WHITELISTED_IDS);

export function isDeveloper(player: Player): boolean {
	return RunService.IsStudio() || SET_OF_DEVELOPER_IDS.has(player.UserId);
}

export function isWhitelisted(player: Player): boolean {
	return RunService.IsStudio() || SET_OF_WHITELISTED_IDS.has(player.UserId);
}
