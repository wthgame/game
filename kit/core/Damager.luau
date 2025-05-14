--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClientCore"):WaitForChild("net"))
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

export type Damage = number | "Normal" | "Heavy" | "Super" | "Lethal"

local Damage: utils.InstanceAttribute<Damage> = prelude.attribute(
	"Damage",
	prelude.t.union(prelude.isPositiveNumber, prelude.t.literal("Normal", "Heavy", "Super", "Lethal")),
	0
)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Damager = kit:tag("Damager", prelude.isBasePart)
	Damager:onActivated(function(_, dam)
		local damage = Damage(dam)
		if typeof(damage) == "number" then
			net.damageSelfVariable.fire(damage)
		else
			net.damageSelf.fire(damage :: any)
		end
	end)
end

return self
