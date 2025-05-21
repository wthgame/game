--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = require(ReplicatedStorage:WaitForChild("WTHClientCore"):WaitForChild("net"))
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @type Damage number | "Normal" | "Double" | "Quadruple" | "Lethal"
--- @within Damager
---
--- Defines the amounts of Damage to be dealt. Positive number can be used to
--- define variable damage values. Otherwise, the following is used:
---
--- | ------------- | -------- |
--- | Name          | Amount   |
--- | ------------- | -------- |
--- | `"Normal"`    | `10`     |
--- | `"Double"`    | `20`     |
--- | `"Quadruple"` | `40`     |
--- | `"Lethal"`    | Infinite |
export type Damage = number | "Normal" | "Double" | "Quadruple" | "Lethal"

--- @class Damager
--- @tag KitObject
---
--- Deals damage to characters that come into contact with them. Damagers
--- typically use fixed values.
local Damager = {}
type Self = typeof(Damager)
Damager.implements = { KitScript = true }

--- @prop Damage Damage
--- @within Damager
--- @tag Attribute
---
--- Amount of Damage that should be dealt. See the `Damage` type.
Damager.Damage = prelude.attribute(
	"Damage",
	prelude.t.union(prelude.isPositiveNumber, prelude.t.literal("Normal", "Heavy", "Super", "Lethal")),
	0
) :: std.Attribute<Damage>

function Damager.run(self: Self, kit: std.Kit)
	local tag = kit:tag("Damager", prelude.isBasePart)
	tag:onActivated(function(_, dam)
		local damage = self.Damage(dam)
		if typeof(damage) == "number" then
			net.damageSelfVariable.fire(damage)
		else
			net.damageSelf.fire(damage :: any)
		end
	end)
end

return Damager
