local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Damage = number | "Normal" | "Heavy" | "Lethal"
type DamagePartAttributes = {
	Damage: Damage,
}

local function initDamageParts(wth: utils.WTH)
	local DamagePart = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "DamagePart",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Damage = "Normal",
		},
		attributeChecks = {
			Damage = utils.t.union(utils.t.numberPositive, utils.t.literal("Normal", "Heavy", "Lethal")),
		},
	} :: utils.Mechanic<BasePart, DamagePartAttributes>

	function DamagePart:loaded(trove, instance, kit)
		trove:add(instance.Touched:Connect(function(toucher)
			if utils.isFromMaybeLocalCharacter(toucher) then
				local damage = self:attribute(instance, "Damage")
				if typeof(damage) == "number" then
					net.mechanics.damageSelfVariable.fire(damage)
				else
					net.mechanics.damageSelf.fire(damage)
				end
			end
		end))
	end

	wth.registerMechanic(DamagePart)
end

return initDamageParts
