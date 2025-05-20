--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local ButtonEnabledAttributes = require("./ButtonEnabledAttributes")
local Invert = ButtonEnabledAttributes.Invert
local KeepCollision = ButtonEnabledAttributes.KeepCollision
local KeepTransparency = ButtonEnabledAttributes.KeepTransparency
local TransitionTime = ButtonEnabledAttributes.TransitionTime
local TransitionEasingStyle = ButtonEnabledAttributes.TransitionEasingStyle
local TransitionEasingDirection = ButtonEnabledAttributes.TransitionEasingDirection
local ActiveTransparency = ButtonEnabledAttributes.ActiveTransparency
local InactiveTransparency = ButtonEnabledAttributes.InactiveTransparency
local KeepEnabled = ButtonEnabledAttributes.KeepEnabled

local TOGGLE_ENABLED_CLASSES: std.Set<string> = {
	Beam = true,
	Constraint = true,
	ParticleEmitter = true,
	Fire = true,
	Sparkles = true,
	Smoke = true,
	Trail = true,
	UIStroke = true,
	UIGradient = true,
}

local TWEEN_CLASSES: std.Map<string, string> = {
	Decal = "Transparency",
	Texture = "Transparency",
	SelectionBox = "Transparency",
	SelectionSphere = "Transparency",
	Frame = "BackgroundTransparency",
	CanvasGroup = "GroupTransparency",
	TextLabel = "TextTransparency",
	ImageLabel = "ImageTransparency",
}

local function updateButtonEnabled(instance: Instance, active: boolean)
	if Invert(instance) then
		active = not active
	end

	instance:SetAttribute("Active", active)

	if instance:IsA("BasePart") then
		if not instance:GetAttribute("InactiveTransparency") then
			instance:SetAttribute("InactiveTransparency", instance.Transparency)
		end

		if not KeepCollision(instance) then
			instance.CanCollide = active
		end

		if not KeepTransparency(instance) then
			prelude.tweenMaybeInstant(
				instance,
				{ Transparency = active and ActiveTransparency(instance) or InactiveTransparency(instance) },
				{
					time = TransitionTime(instance),
					easingStyle = TransitionEasingStyle(instance),
					easingDirection = TransitionEasingDirection(instance),
				}
			)
		end

		return
	end

	if not KeepEnabled(instance) then
		for class, property in TOGGLE_ENABLED_CLASSES do
			if instance:IsA(class) then
				(instance :: any).Enabled = active
				break
			end
		end
	end

	-- TODO: could be more robust?
	if not KeepTransparency(instance) then
		for class, property in TWEEN_CLASSES do
			if not instance:IsA(class) then
				continue
			end

			if not instance:GetAttribute("InactiveTransparency") then
				instance:SetAttribute("InactiveTransparency", (instance :: any)[property])
			end

			prelude.tweenMaybeInstant(
				instance,
				{ [property] = active and ActiveTransparency(instance) or InactiveTransparency(instance) },
				{
					time = TransitionTime(instance),
					easingStyle = TransitionEasingStyle(instance),
					easingDirection = TransitionEasingDirection(instance),
				}
			)

			return
		end
	end
end

return updateButtonEnabled
