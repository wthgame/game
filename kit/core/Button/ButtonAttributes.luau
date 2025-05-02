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
local PlaySound = utils.attribute("PlaySound", utils.t.boolean, true)
local PressOffset = utils.attribute(
	"PressOffset",
	utils.t.union(utils.t.number, utils.t.Vector3, utils.t.CFrame),
	Vector3.new(0, -0.5, 0)
)

return {
	ButtonId = ButtonId,
	ButtonPressed = ButtonPressed,
	HoldDuration = HoldDuration,
	MaxActivationDistance = MaxActivationDistance,
	Cooldown = Cooldown,
	Duration = Duration,
	PlaySound = PlaySound,
	PressOffset = PressOffset,
}
