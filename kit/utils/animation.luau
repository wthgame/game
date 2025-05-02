--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local TweenService = game:GetService("TweenService")
local t = require("./packages/t")
local types = require("./types")

export type TweenConfig = {
	time: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	repeatCount: number?,
	reverse: boolean?,
	delayTime: number?,
}

local isEasingStyle = t.enum(Enum.EasingStyle)
local isEasingDirection = t.enum(Enum.EasingDirection)

local function tweenInfoFromTweenConfig(config: types.TweenConfig)
	return TweenInfo.new(
		config.time or 1,
		config.easingStyle or Enum.EasingStyle.Linear,
		config.easingDirection or Enum.EasingDirection.Out,
		config.repeatCount or 0,
		config.reverse or false,
		config.delayTime or 0
	)
end

local function tweenConfigFromAttributes(instance: Instance, attributePrefix: string): TweenConfig
	local timeAttribute = attributePrefix .. "Time"
	local easingStyleAttribute = attributePrefix .. "EasingStyle"
	local easingDirectionAttribute = attributePrefix .. "EasingDirection"

	local attributes = instance:GetAttributes()

	local realTime = attributes[timeAttribute]
	local realEasingStyle = attributes[easingStyleAttribute]
	local realEasingDirection = attributes[easingDirectionAttribute]

	return {
		time = if t.numberPositive(realTime) then realTime :: number else nil,
		easingStyle = if isEasingStyle(realEasingStyle) then realEasingStyle :: any else nil,
		easingDirection = if isEasingDirection(realEasingDirection) then realEasingDirection :: any else nil,
	}
end

local function tween(instance: Instance, propertyTable: { [string]: unknown }, config: types.TweenConfig?)
	local tweenInfo = tweenInfoFromTweenConfig(config or {})

	local tween = TweenService:Create(instance, tweenInfo, propertyTable)
	tween.Completed:Once(function()
		tween:Destroy()
	end)

	tween:Play()
	return tween
end

local function tweenMaybeInstant(instance: Instance, propertyTable: { [string]: unknown }, config: types.TweenConfig?)
	local tweenInfo = tweenInfoFromTweenConfig(config or {})

	if tweenInfo.Time > 0 then
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
	tweenInfoFromTweenConfig = tweenInfoFromTweenConfig,
	tweenConfigFromAttributes = tweenConfigFromAttributes,
	tween = tween,
	tweenMaybeInstant = tweenMaybeInstant,
}
