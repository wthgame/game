--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonActivatedAttributes = require("./ButtonActivatedAttributes")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local KeepCollision = ButtonActivatedAttributes.KeepCollision
local KeepTransparency = ButtonActivatedAttributes.KeepTransparency
local TransitionTime = ButtonActivatedAttributes.TransitionTime
local TransitionEasingStyle = ButtonActivatedAttributes.TransitionEasingStyle
local TransitionEasingDirection = ButtonActivatedAttributes.TransitionEasingDirection
local ActiveTransparency = ButtonActivatedAttributes.ActiveTransparency
local InactiveTransparency = ButtonActivatedAttributes.InactiveTransparency

local function updateButtonActivatedPart(instance: BasePart, active: boolean)
	if not instance:GetAttribute("OriginalTransparency") then
		instance:SetAttribute("OriginalTransparency", instance.Transparency)
	end

	if not KeepCollision(instance) then
		instance.CanCollide = active
	end

	if not KeepTransparency(instance) then
		local time = TransitionTime(instance)
		if time < 0.25 then
			instance.Transparency = active and ActiveTransparency(instance) or InactiveTransparency(instance)
		else
			utils.tween(
				instance,
				{ Transparency = active and ActiveTransparency(instance) or InactiveTransparency(instance) },
				{
					time = TransitionTime(instance),
					easingStyle = TransitionEasingStyle(instance),
					easingDirection = TransitionEasingDirection(instance),
				}
			)
		end
	end
end

return updateButtonActivatedPart
