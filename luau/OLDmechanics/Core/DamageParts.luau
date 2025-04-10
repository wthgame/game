--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local DAMAGE_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local self = {} :: utils.Mechanic<{}, Instance>
self.type = "Mechanic"
self.name = "DamageParts"
self.attributes = {}
self.defaultAttributes = {}
self.instanceCheck = utils.t.Instance

-- TODO: account for parts being removed/added
function self:mechanize(ctx)
	local damageParts: { [BasePart]: true } = {}

	for _, descendant in ctx.instance:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:HasTag("DamagePart") then
			damageParts[descendant] = true
		end
	end

	for part in damageParts do
		ctx.trove:add(part.Touched:Connect(function(toucher)
			if not utils.checkTouched(toucher, DAMAGE_PART_TOUCH_CONFIG) then
				return
			end

			local amountNow = part:GetAttribute("Amount")
			if typeof(amountNow) == "string" then
				net.mechanics.damageSelf.fire(amountNow :: never)
			elseif utils.t.numberPositive(amountNow) then
				net.mechanics.damageSelfVariable.fire(amountNow :: number)
			else
				ctx.logWarn("Invalid amount", amountNow, "for DamagePart", part:GetFullName())
			end
		end))
	end
end

return self
