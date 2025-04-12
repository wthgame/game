--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local wth = require(ReplicatedStorage:WaitForChild("Lib"))

type Self = wth.Mechanic<{
	DamageParts: wth.Entity<BasePart>,
	DamageAmount: (instance: Instance) -> number | "Normal" | "Heavy" | "Lethal",
}>

local DAMAGE_PART_TOUCH_CONFIG: wth.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local mech = {} :: Self
mech.type = "Mechanic"
mech.name = "DamageParts"

mech.DamageParts = wth.trackCollectionServiceTag("DamageParts", wth.t.instanceIsA("BasePart"))
mech.DamageAmount = wth.createAttributeReconciler(
	"DamageAmount",
	wth.t.union(wth.t.numberPositive, wth.t.literal("Normal", "Heavy", "Lethal")) :: any,
	0
)

function mech:init(schedule)
	local queryDamageParts = wth.world:query(self.DamageParts)

	local function checkDamagePartChildren()
		for entity, part in queryDamageParts:iter() do
			local damageAmountNow = self.DamageAmount(part)
			for _, toucher in workspace:GetPartsInPart(part) do
				if wth.checkTouched(toucher, DAMAGE_PART_TOUCH_CONFIG) then
					if typeof(damageAmountNow) == "string" then
						net.mechanics.damageSelf.fire(damageAmountNow :: never)
					elseif wth.t.numberPositive(damageAmountNow) then
						net.mechanics.damageSelfVariable.fire(damageAmountNow :: number)
						-- else
						-- wth.logWarn("Invalid amount", amountNow, "for DamagePart", part:GetFullName())
					end

					break
				end
			end
		end
	end

	schedule(checkDamagePartChildren)
end

return mech
