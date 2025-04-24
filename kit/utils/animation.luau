--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local TweenService = game:GetService("TweenService")
local types = require("./types")

local function tween(instance: Instance, propertyTable: { [string]: unknown }, config: types.TweenConfig?)
	local config: types.TweenConfig = config or {}

	local tweenInfo = TweenInfo.new(
		config.time or 1,
		config.easingStyle or Enum.EasingStyle.Linear,
		config.easingDirection or Enum.EasingDirection.Out,
		config.repeatCount or 0,
		config.reverse or false,
		config.delayTime or 0
	)

	local tween = TweenService:Create(instance, tweenInfo, propertyTable)
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	tween:Play()
	return tween
end

local function tweenMaybeInstant(instance: Instance, propertyTable: { [string]: unknown }, config: types.TweenConfig?)
	local config: types.TweenConfig = config or {}
	local time = config.time or 1

	if time > 0 then
		local tweenInfo = TweenInfo.new(
			time,
			config.easingStyle or Enum.EasingStyle.Linear,
			config.easingDirection or Enum.EasingDirection.Out,
			config.repeatCount or 0,
			config.reverse or false,
			config.delayTime or 0
		)

		local tween = TweenService:Create(instance, tweenInfo, propertyTable)
		tween.Completed:Once(function()
			tween:Destroy()
		end)

		tween:Play()
	else
		for property, value in propertyTable do
			(instance :: any)[property] = value
		end
	end
end

return {
	tween = tween,
	tweenMaybeInstant = tweenMaybeInstant,
}
