--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local DAMAGE_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local self = {} :: utils.Mechanic
self.type = "Mechanic"
self.name = "DamageParts"

function self.attach(wth)
	local DamageParts: utils.Entity<Instance> = wth.createMechanicTag("DamageParts")
	local DamagePartChildren: utils.Entity<{ [BasePart]: true }> = wth.world:component()
	wth.world:set(DamagePartChildren, utils.Jecs.Name, "DamagePartChildren")

	local queryDamageParts = wth.world:query(DamageParts):cached()

	local function updateDamageParts()
		for entity, damageParts in queryDamageParts:iter() do
			local damagePartChildren: { [BasePart]: true } = {}

			for _, descendant in damageParts:GetChildren() do
				if descendant:IsA("BasePart") and descendant:HasTag("DamagePart") then
					damagePartChildren[descendant] = true
				end
			end

			wth.world:set(entity, DamagePartChildren, damagePartChildren)
		end
	end

	local queryDamagePartChildren = wth.world:query(DamagePartChildren):cached()

	local function checkDamagePartChildren()
		for entity, child in queryDamagePartChildren:iter() do
			for part in child do
				local amountNow = part:GetAttribute("Amount")
				for _, toucher in workspace:GetPartsInPart(part) do
					if utils.checkTouched(toucher, DAMAGE_PART_TOUCH_CONFIG) then
						if typeof(amountNow) == "string" then
							net.mechanics.damageSelf.fire(amountNow :: never)
						elseif utils.t.numberPositive(amountNow) then
							net.mechanics.damageSelfVariable.fire(amountNow :: number)
							-- else
							-- wth.logWarn("Invalid amount", amountNow, "for DamagePart", part:GetFullName())
						end

						break
					end
				end
			end
		end
	end

	wth.pushSystems(updateDamageParts, checkDamagePartChildren)
end

return self
