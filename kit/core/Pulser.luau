--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

type ColorPulserType = "Color3" | "ColorSequence" | "BrickColor"
type NumberPulserType = "number" | "NumberSequence" | "NumberRange"
type PulserType = ColorPulserType | NumberPulserType

local MinimumDistance = prelude.attribute("MinimumDistance", prelude.isPositiveNumber, -math.huge)
local MaximumDistance = prelude.attribute("MaximumDistance", prelude.isPositiveNumber, 100)

local logger = prelude.createLogger("Pulser")
local isSequence = prelude.t.union(prelude.t.ColorSequence, prelude.t.NumberSequence)
local isColorPulserType: utils.check<PulserType> = prelude.t.literal("Color3", "ColorSequence", "BrickColor")
local isNumberPulserType: utils.check<PulserType> = prelude.t.literal("number", "NumberSequence", "NumberRange")
local isPulserType: utils.check<PulserType> = prelude.t.union(isColorPulserType, isNumberPulserType)

local self = {} :: utils.KitScript
self.type = "KitScript"

local function setPropertyUnsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

function self:run(kit: utils.Kit)
	local Pulser = kit:tag("Pulser")

	local localPlayer = Players.LocalPlayer

	kit:onRender(function()
		local loadedLifetime = kit:loadedLifetime()
		for _, toPulse in Pulser:instances() do
			if not prelude.Active(toPulse) then
				continue
			end

			local position: Vector3
			if toPulse:IsA("BasePart") then
				position = toPulse.Position
			else
				local ancestor = toPulse:FindFirstAncestorWhichIsA("BasePart")
				if ancestor then
					position = ancestor.Position
				end
			end

			if position then
				local distance = localPlayer:DistanceFromCharacter(position)
				if distance < MinimumDistance(toPulse) or distance > MaximumDistance(toPulse) then
					continue
				end
			end

			local propertySequences: utils.Map<string, ColorSequence | NumberSequence> = {}
			local offsets: utils.Map<string, number> = {}
			local durations: utils.Map<string, number> = {}
			local types: utils.Map<string, PulserType> = {}

			for attributeName, value in toPulse:GetAttributes() do
				local property = attributeName:match("^Property_(%w+)")
				if property then
					assert(isSequence(value))
					propertySequences[property] = value :: any
					continue
				end

				local offsetForProperty = attributeName:match("^PulseOffset_(%w+)")
				if offsetForProperty then
					assert(prelude.t.number(value))
					offsets[offsetForProperty] = value :: any
					continue
				end

				local durationForProperty = attributeName:match("^PulseDuration_(%w+)")
				if durationForProperty then
					assert(prelude.isPositiveNumber(value))
					durations[durationForProperty] = value :: any
					continue
				end

				local typeForProperty = attributeName:match("^PulserType_(%w+)")
				if typeForProperty then
					assert(isPulserType(value))
					types[typeForProperty] = value :: any
					continue
				end
			end

			for property, sequence in propertySequences do
				local duration = durations[property] or 1
				local progress = loadedLifetime % duration
				local time = progress / duration
				local timeOffset = offsets[property]
				if timeOffset then
					time += timeOffset
				end
				time %= 1

				local newValue: unknown

				if typeof(sequence) == "ColorSequence" then
					local color = utils.color.pickTimeInColorSequence(sequence, time)
					local propertyType: ColorPulserType = (types[property] or "Color3") :: any
					if not isColorPulserType(propertyType) then
						logger:warn(
							"Expected property",
							property,
							"of Pulser",
							toPulse:GetFullName(),
							"to be Color3, ColorSequence, or BrickColor, but got",
							propertyType,
							"instead."
						)
					end
					newValue = if propertyType == "Color3"
						then color
						elseif propertyType == "ColorSequence" then ColorSequence.new(color)
						elseif propertyType == "BrickColor" then BrickColor.new(color)
						else utils.never()
				elseif typeof(sequence) == "NumberSequence" then
					local num = utils.math.pickTimeInNumberSequence(sequence, time)
					local propertyType: NumberPulserType = (types[property] or "number") :: any
					if not isNumberPulserType(propertyType) then
						logger:warn(
							"Expected property",
							property,
							"of Pulser",
							toPulse:GetFullName(),
							"to be number, NumberSequence, or NumberRange, but got",
							propertyType,
							"instead."
						)
					end
					newValue = if propertyType == "number"
						then num
						elseif propertyType == "NumberSequence" then NumberSequence.new(num)
						elseif propertyType == "NumberRange" then NumberRange.new(num)
						else utils.never()
				end

				local setSuccess = pcall(setPropertyUnsafe, toPulse, property, newValue)
				if not setSuccess then
					-- TODO: more helpful error handling
					logger:warn("Cannot update property", property, "of Pulser", toPulse:GetFullName())
				end
			end
		end
	end)
end

return self
