--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local debounced: std.Set<BasePart> = {}

--- @class Tripper
--- @tag KitObject
--- @tag Activatable
---
--- Trips the player, seating them, when activated.
local Tripper = {}
type Self = typeof(Tripper)
Tripper.implements = { KitScript = true }

--- @prop Cooldown number
--- @within Tripper
--- @tag Attribute
---
--- Defines the cooldown period in seconds after a `Tripper` has been
--- activated, before it can be used again.
Tripper.Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)

local function tripPlayer(trove: std.Trove, tripper: BasePart)
	if not debounced[tripper] then
		local humanoid = assert(prelude.getMaybeHumanoid(), "can be assumed it exists")
		humanoid.Sit = true
		debounced[tripper] = true
		task.delay(Tripper.Cooldown(tripper), function()
			debounced[tripper] = nil
		end)
	end
end

function Tripper:run(kit: std.Kit)
	kit:tag("Tripper", prelude.isBasePart):onActivated(tripPlayer)
end

return Tripper
