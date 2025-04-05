import { World } from "@rbxts/jecs";

export const world = new World();

export const components = table.freeze({
	Mechanic: world.component(),
});
