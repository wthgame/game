--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Invert = utils.attribute("Invert", utils.t.boolean, false)
local KeepCollision = utils.attribute("KeepCollision", utils.t.boolean, false)
local KeepTransparency = utils.attribute("KeepTransparency", utils.t.boolean, false)
local KeepEnabled = utils.attribute("KeepEnabled", utils.t.boolean, false)
local ActiveTransparency = utils.attribute("ActiveTransparency", utils.t.numberConstrained(0, 1), 0)
local InactiveTransparency = utils.attribute("InactiveTransparency", utils.t.numberConstrained(0, 1), 0.6)
local TransitionTime = utils.attribute("TransitionTime", utils.t.numberPositive, 0.25)
-- NOTE: Enums can be used as attributes, it just needs to be added by a script
local TransitionEasingStyle = utils.attribute(
	"TransitionEasingStyle",
	utils.t.enum(Enum.EasingStyle) :: utils.check<Enum.EasingStyle>,
	Enum.EasingStyle.Quad
)
local TransitionEasingDirection = utils.attribute(
	"TransitionEasingDirection",
	utils.t.enum(Enum.EasingDirection) :: utils.check<Enum.EasingDirection>,
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
