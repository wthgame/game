--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type ShoverDirectionAttributes = {
	Delay: std.Attribute<number>,
	Power: std.Attribute<number>,
}

local SHOVER_DIRECTION_ATTRIBUTES = {
	In = {
		Delay = prelude.Attribute("InDelay", prelude.isPositiveNumber, 1),
		Power = prelude.Attribute("InPower", prelude.isPositiveNumber, 0),
	},
	Out = {
		Delay = prelude.Attribute("OutDelay", prelude.isPositiveNumber, 1),
		Power = prelude.Attribute("OutPower", prelude.isPositiveNumber, 0),
	},
}

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function shove(direction: "In" | "Out", shover: Instance, ancestor: Instance)
	local attributes: ShoverDirectionAttributes = SHOVER_DIRECTION_ATTRIBUTES[direction]
	task.wait(attributes.Delay(shover))
	if prelude.Enabled(shover) and shover:IsDescendantOf(ancestor) then
		local power = attributes.Power(shover)
		for _, descendant in shover:GetDescendants() do
			if descendant.Name == "ShoverConstraint" and descendant:IsA("PrismaticConstraint") then
				descendant.LinearResponsiveness = power
				descendant.Speed = power
				descendant.TargetPosition = if direction == "Out" then descendant.UpperLimit else 0
			end
		end
	end
end

function self:run(kit: std.Kit)
	local Shover = kit:tag("Shover")
	Shover:onLoaded(function(trove, shover)
		local stop = false
		kit.trove:add(function()
			stop = true
		end)
		while true do
			if stop then
				return
			end
			shove("In", shover, kit.mechanics)
			shove("Out", shover, kit.mechanics)
		end
	end)
end

return self
