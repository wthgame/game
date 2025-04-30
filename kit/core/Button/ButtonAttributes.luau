--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

export type ActivatedBy = "Touch" | "Prompt" | "Click" | "Control"

local ButtonId = utils.attribute("ButtonId", utils.t.string)
local ButtonPressed = utils.attribute("ButtonPressed", utils.t.boolean, false)
local HoldDuration = utils.attribute("HoldDuration", utils.t.numberPositive, 0)
local MaxActivationDistance = utils.attribute("MaxActivationDistance", utils.t.numberPositive, math.huge)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
local Duration = utils.attribute("Duration", utils.t.numberPositive, 0)
local PressOffset = utils.attribute(
	"PressOffset",
	utils.t.union(utils.t.number, utils.t.Vector3, utils.t.CFrame),
	Vector3.new(0, -0.5, 0)
)
local PressTime = utils.attribute("PressTime", utils.t.numberPositive, 0.25)
-- NOTE: Enums can be used as attributes, it just needs to be added by a script
local PressEasingStyle = utils.attribute(
	"PressEasingStyle",
	utils.t.enum(Enum.EasingStyle) :: utils.check<Enum.EasingStyle>,
	Enum.EasingStyle.Quad
)
local PressEasingDirection = utils.attribute(
	"PressEasingDirection",
	utils.t.enum(Enum.EasingDirection) :: utils.check<Enum.EasingDirection>,
	Enum.EasingDirection.Out
)

return {
	ButtonId = ButtonId,
	ButtonPressed = ButtonPressed,
	HoldDuration = HoldDuration,
	MaxActivationDistance = MaxActivationDistance,
	Cooldown = Cooldown,
	Duration = Duration,
	PressOffset = PressOffset,
	PressTime = PressTime,
	PressEasingStyle = PressEasingStyle,
	PressEasingDirection = PressEasingDirection,
}
