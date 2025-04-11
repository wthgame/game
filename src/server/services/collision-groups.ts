import { OnInit, Service } from "@flamework/core";
import { PhysicsService } from "@rbxts/services";

interface CollisionGroup {
	collides: ReadonlySet<string>;
	ignores: ReadonlySet<string>;
	doNotCreate?: boolean;
}

export const COLLISION_GROUPS: Record<string, CollisionGroup> = {
	Default: {
		collides: new ReadonlySet(["DoNotCollideWithSelf"]),
		ignores: new ReadonlySet(["NeverCollide"]),
		doNotCreate: true,
	},
	Player: {
		collides: new ReadonlySet(["DoNotCollideWithSelf"]),
		ignores: new ReadonlySet(["NeverCollide", "OtherPlayers", "DoNotCollideWithPlayers"]),
	},
	OtherPlayers: {
		collides: new ReadonlySet(),
		ignores: new ReadonlySet(["NeverCollide"]),
	},
	Mechanics: {
		collides: new ReadonlySet(["DoNotCollideWithSelf"]),
		ignores: new ReadonlySet(["NeverCollide", "OtherPlayers"]),
	},
	OnlyCollideWithPlayers: {
		collides: new ReadonlySet([]),
		ignores: new ReadonlySet(["Default", "OtherPlayers", "DoNotCollideWithPlayers", "Mechanics", "NeverCollide"]),
	},
	DoNotCollideWithPlayers: {
		collides: new ReadonlySet([]),
		ignores: new ReadonlySet(["NeverCollide", "OtherPlayers"]),
	},
	DoNotCollideWithSelf: {
		collides: new ReadonlySet([]),
		ignores: new ReadonlySet(["DoNotCollideWithSelf", "NeverCollide"]),
	},
	NeverCollide: {
		collides: new ReadonlySet([]),
		ignores: new ReadonlySet(["NeverCollide"]),
	},
	AlwaysCollide: {
		collides: new ReadonlySet([]),
		// Lie detected
		ignores: new ReadonlySet(["OtherPlayers", "NeverCollide"]),
	},
};

@Service()
export class CollisionGroupsService implements OnInit {
	onInit(): void {
		for (const [name, collisions] of pairs(COLLISION_GROUPS)) {
			if (collisions.doNotCreate) continue;
			PhysicsService.RegisterCollisionGroup(name);
		}

		for (const [name, { collides, ignores }] of pairs(COLLISION_GROUPS)) {
			for (const other of collides) PhysicsService.CollisionGroupSetCollidable(name, other, true);
			for (const other of ignores) PhysicsService.CollisionGroupSetCollidable(name, other, false);
		}
	}
}
