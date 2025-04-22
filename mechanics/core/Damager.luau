--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClientCore"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Damage = number | "Normal" | "Heavy" | "Super" | "Lethal"

local function init(wth: utils.WTH)
	local Damager = wth:tag("Damager", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	local Damage = utils.attribute(
		"Damage",
		utils.t.union(utils.t.numberPositive, utils.t.literal("Normal", "Heavy", "Super", "Lethal")) :: utils.check<Damage>,
		0
	)

	Damager:onLoaded(function(trove, dam)
		trove:add(dam.Touched:Connect(function(toucher)
			if utils.isEnabled(dam) and utils.isFromMaybeLocalCharacter(toucher) then
				local damage = Damage(dam)
				if typeof(damage) == "number" then
					net.damageSelfVariable.fire(damage)
				else
					net.damageSelf.fire(damage :: any)
				end
			end
		end))
	end)
end

return init
