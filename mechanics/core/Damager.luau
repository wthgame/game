--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Damage = number | "Normal" | "Heavy" | "Super" | "Lethal"
type DamagerAttributes = {
	Enabled: boolean,
	Damage: Damage,
}

local function init(wth: utils.WTH)
	local Damager = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Damager",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Enabled = true,
			Damage = "Normal",
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			Damage = utils.t.union(utils.t.numberPositive, utils.t.literal("Normal", "Heavy", "Super", "Lethal")),
		},
	} :: utils.Mechanic<BasePart, DamagerAttributes>

	function Damager:loaded(trove, instance, kit)
		trove:add(instance.Touched:Connect(function(toucher)
			if self:attribute(instance, "Enabled") and utils.isFromMaybeLocalCharacter(toucher) then
				local damage = self:attribute(instance, "Damage")
				if typeof(damage) == "number" then
					net.kit.damageSelfVariable.fire(damage)
				else
					net.kit.damageSelf.fire(damage)
				end
			end
		end))
	end

	wth.registerMechanic(Damager)
end

return init
