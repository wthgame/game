--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

type ShoverDirectionAttributes = {
	delay: utils.InstanceAttribute<number>,
	power: utils.InstanceAttribute<number>,
}

local SHOVER_DIRECTION_ATTRIBUTES = {
	In = {
		delay = utils.attribute("InDelay", utils.isPositiveNumber, 1),
		power = utils.attribute("InPower", utils.isPositiveNumber, 0),
	},
	Out = {
		delay = utils.attribute("OutDelay", utils.isPositiveNumber, 1),
		power = utils.attribute("OutPower", utils.isPositiveNumber, 0),
	},
}

local self = {} :: utils.KitScript
self.type = "KitScript"

local function shove(direction: "In" | "Out", shover: Instance, ancestor: Instance)
	local attributes: ShoverDirectionAttributes = SHOVER_DIRECTION_ATTRIBUTES[direction]
	task.wait(attributes.delay(shover))
	if utils.Active(shover) and shover:IsDescendantOf(ancestor) then
		local power = attributes.power(shover)
		for _, descendant in shover:GetDescendants() do
			if descendant.Name == "ShoverConstraint" and descendant:IsA("PrismaticConstraint") then
				descendant.LinearResponsiveness = power
				descendant.Speed = power
				descendant.TargetPosition = if direction == "Out" then descendant.UpperLimit else 0
			end
		end
	end
end

function self:run(kit: utils.Kit)
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
