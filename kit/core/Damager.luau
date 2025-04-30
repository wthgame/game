--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClientCore"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

export type Damage = number | "Normal" | "Heavy" | "Super" | "Lethal"

local Damage = utils.attribute(
	"Damage",
	utils.t.union(utils.t.numberPositive, utils.t.literal("Normal", "Heavy", "Super", "Lethal")) :: utils.check<Damage>,
	0
)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Damager = kit:tag("Damager", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Damager:onLoaded(function(trove, dam)
		utils.connectActivation(trove, dam, function()
			local damage = Damage(dam)
			if typeof(damage) == "number" then
				net.damageSelfVariable.fire(damage)
			else
				net.damageSelf.fire(damage :: any)
			end
		end)
	end)
end

return self
