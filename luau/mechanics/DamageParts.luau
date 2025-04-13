--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type DamageType = number | "Normal" | "Heavy" | "Lethal"

local DAMAGE_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "DamageParts"

function mech:init(wth)
	local DamagePart: utils.Entity<BasePart> = wth:useTag("DamagePart", utils.t.instanceIsA("BasePart"))
	local DamageAmount: utils.Entity<DamageType> = wth:useAttribute(
		"DamageAmount",
		DamagePart,
		utils.t.union(utils.t.numberPositive, utils.t.literal("Normal", "Heavy", "Lethal")) :: any,
		0
	)

	local queryDamagePart = wth.world:query(DamagePart, DamageAmount):cached()

	local function checkDamagePartChildren()
		for entity, part, amount in queryDamagePart:iter() do
			for _, toucher in workspace:GetPartsInPart(part) do
				if utils.checkTouched(toucher, DAMAGE_PART_TOUCH_CONFIG) then
					if typeof(amount) == "string" then
						net.mechanics.damageSelf.fire(amount :: never)
					elseif utils.t.numberPositive(amount) then
						net.mechanics.damageSelfVariable.fire(amount :: number)
						-- else
						-- wth.logWarn("Invalid amount", amountNow, "for DamagePart", part:GetFullName())
					end

					break
				end
			end
		end
	end

	wth:schedule(checkDamagePartChildren)
end

return mech
