--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local Invert = prelude.Attribute("Invert", prelude.isBoolean, false)
local KeepCollision = prelude.Attribute("KeepCollision", prelude.isBoolean, false)
local KeepTransparency = prelude.Attribute("KeepTransparency", prelude.isBoolean, false)
local KeepEnabled = prelude.Attribute("KeepEnabled", prelude.isBoolean, false)
local ActiveTransparency = prelude.Attribute("ActiveTransparency", prelude.t.numberConstrained(0, 1), 0)
local InactiveTransparency = prelude.Attribute("InactiveTransparency", prelude.t.numberConstrained(0, 1), 0.6)
local TransitionTime = prelude.Attribute("TransitionTime", prelude.isPositiveNumber, 0.25)
-- NOTE: Enums can be used as attributes, it just needs to be added by a script
local TransitionEasingStyle = prelude.Attribute(
	"TransitionEasingStyle",
	prelude.t.enum(Enum.EasingStyle) :: std.check<Enum.EasingStyle>,
	Enum.EasingStyle.Quad
)
local TransitionEasingDirection = prelude.Attribute(
	"TransitionEasingDirection",
	prelude.t.enum(Enum.EasingDirection) :: std.check<Enum.EasingDirection>,
	Enum.EasingDirection.Out
)

return {
	Invert = Invert,
	KeepCollision = KeepCollision,
	KeepTransparency = KeepTransparency,
	KeepEnabled = KeepEnabled,
	ActiveTransparency = ActiveTransparency,
	InactiveTransparency = InactiveTransparency,
	TransitionTime = TransitionTime,
	TransitionEasingStyle = TransitionEasingStyle,
	TransitionEasingDirection = TransitionEasingDirection,
}
