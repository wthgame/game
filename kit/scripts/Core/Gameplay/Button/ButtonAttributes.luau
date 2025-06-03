--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

export type ActivatedBy = "Touch" | "Prompt" | "Click" | "Control"

local ButtonId = prelude.Attribute("ButtonId", prelude.t.string)
local ButtonPressed = prelude.Attribute("ButtonPressed", prelude.isBoolean, false)
local HoldDuration = prelude.Attribute("HoldDuration", prelude.isPositiveNumber, 0)
local MaxActivationDistance = prelude.Attribute("MaxActivationDistance", prelude.isPositiveNumber, math.huge)
local Cooldown = prelude.Attribute("Cooldown", prelude.isPositiveNumber, 0)
local Duration = prelude.Attribute("Duration", prelude.isPositiveNumber, 0)
local PlaySound = prelude.Attribute("PlaySound", prelude.isBoolean, true)
local PressOffset = prelude.Attribute(
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
