--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local t = std.packages.t

local BoxTypes = {}

export type BoxSpawnBehavior = {
	implements: { BoxSpawnBehavior: true },
	name: string,
	predicate: ((box: BasePart) -> boolean)?,
	spawn: (self: BoxSpawnBehavior, trove: std.Trove, box: BasePart) -> (),
}

BoxTypes.isBoxSpawnBehavior = t.interface({
	implements = t.interface({ BoxSpawnBehavior = t.literal(true) }),
	name = t.string,
	predicate = t.optional(t.callback),
	spawn = t.callback,
}) :: std.check<BoxSpawnBehavior>

return BoxTypes
