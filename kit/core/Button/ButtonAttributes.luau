--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

export type ActivatedBy = "Touch" | "Prompt" | "Click" | "Control"

local ButtonId = prelude.attribute("ButtonId", prelude.t.string)
local ButtonPressed = prelude.attribute("ButtonPressed", prelude.isBoolean, false)
local HoldDuration = prelude.attribute("HoldDuration", prelude.isPositiveNumber, 0)
local MaxActivationDistance = prelude.attribute("MaxActivationDistance", prelude.isPositiveNumber, math.huge)
local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
local Duration = prelude.attribute("Duration", prelude.isPositiveNumber, 0)
local PlaySound = prelude.attribute("PlaySound", prelude.isBoolean, true)
local PressOffset = prelude.attribute(
	"PressOffset",
	prelude.t.union(prelude.t.number, prelude.t.Vector3, prelude.t.CFrame),
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
