--!strict

-- WELCOME TO HELL: COMMENT MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type LavaConfig = {
	Amount: number | "Normal" | "Harmful" | "Lethal",
}

local self = {} :: utils.Mechanic<LavaConfig>
self.type = "Mechanic"
self.name = "Lava"

self.configCheck = {
	Amount = utils.t.union(
		utils.t.numberPositive,
		utils.t.unionList({ utils.t.literal("Normal"), utils.t.literal("Harmful"), utils.t.literal("Lethal") })
	),
}

self.instanceCheck = utils.t.instanceIsA("BasePart")

function self:attach(mech)
	local parent = mech.parent
	assert(parent:IsA("BasePart"), "Luau")

	-- TODO: touch utility
	parent.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		local amountNow = mech.config.Amount
		if typeof(amountNow) == "string" then
			net.mechanics.damageSelf.fire(amountNow :: never)
		else
			net.mechanics.damageSelfVariable.fire(amountNow)
		end
	end)
end

return utils.mechanic(self)
