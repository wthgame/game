--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)

local debounced: std.Set<BasePart> = {}

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function tripPlayer(trove: std.Trove, tripper: BasePart)
	if not debounced[tripper] then
		local humanoid = assert(prelude.getMaybeHumanoid(), "can be assumed it exists")
		humanoid.Sit = true
		debounced[tripper] = true
		task.delay(Cooldown(tripper), function()
			debounced[tripper] = nil
		end)
	end
end

function self:run(kit: std.Kit)
	local Tripper = kit:tag("Tripper", prelude.isBasePart)
	Tripper:onActivated(tripPlayer)
end

return self
