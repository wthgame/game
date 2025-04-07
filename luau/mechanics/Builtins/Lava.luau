--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClient"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type LavaAttributes = {
	Amount: number | "Normal" | "Harmful" | "Lethal",
}

local LAVA_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local self = {} :: utils.Mechanic<LavaAttributes, BasePart>
self.type = "Mechanic"
self.name = "Lava"

self.attributes = {
	Amount = utils.t.union(
		utils.t.numberPositive,
		utils.t.unionList({ utils.t.literal("Normal"), utils.t.literal("Harmful"), utils.t.literal("Lethal") })
	),
}

self.defaultAttributes = {
	Amount = "Normal",
}

self.instanceCheck = utils.t.instanceIsA("BasePart")

function self:mechanize(ctx: utils.MechanizeContext<LavaAttributes, BasePart>)
	ctx:pushTasks(ctx.instance.Touched:Connect(function(toucher)
		if not utils.checkTouched(toucher, LAVA_TOUCH_CONFIG) then
			return
		end

		local amountNow = ctx:getAttribute("Amount" :: "Amount")
		if typeof(amountNow) == "string" then
			net.mechanics.damageSelf.fire(amountNow :: never)
		else
			net.mechanics.damageSelfVariable.fire(amountNow :: number)
		end
	end))
end

return self
