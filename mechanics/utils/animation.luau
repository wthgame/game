--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local TweenService = game:GetService("TweenService")
local types = require("./types")

local function tween(instance: Instance, config: types.TweenConfig?, propertyTable: { [string]: unknown })
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

return {
	tween = tween,
}
