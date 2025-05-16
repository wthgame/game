--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type ColorSequencerType = "Color3" | "ColorSequence" | "BrickColor"
type NumberSequencerType = "number" | "NumberSequence" | "NumberRange"
type SequencerType = ColorSequencerType | NumberSequencerType

local MinimumDistance = prelude.attribute("MinimumDistance", prelude.isPositiveNumber, -math.huge)
local MaximumDistance = prelude.attribute("MaximumDistance", prelude.isPositiveNumber, 100)

local logger = prelude.createLogger("Sequencer")
local isSequence = prelude.t.union(prelude.t.ColorSequence, prelude.t.NumberSequence)
local isColorSequencerType: std.check<SequencerType> = prelude.t.literal("Color3", "ColorSequence", "BrickColor")
local isNumberSequencerType: std.check<SequencerType> = prelude.t.literal("number", "NumberSequence", "NumberRange")
local isSequencerType: std.check<SequencerType> = prelude.t.union(isColorSequencerType, isNumberSequencerType)

local self = {} :: std.KitScript
self.type = "KitScript"

local function setPropertyUnsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

function self:run(kit: std.Kit)
	local Sequencer = kit:tag("Sequencer")

	local localPlayer = Players.LocalPlayer

	kit:onRender(function()
		local loadedLifetime = kit:loadedLifetime()
		for _, toUpdate in Sequencer:instances() do
			if not prelude.Active(toUpdate) then
				continue
			end

			local position: Vector3
			if toUpdate:IsA("BasePart") then
				position = toUpdate.Position
			else
				local ancestor = toUpdate:FindFirstAncestorWhichIsA("BasePart")
				if ancestor then
					position = ancestor.Position
				end
			end

			if position then
				local distance = localPlayer:DistanceFromCharacter(position)
				if distance < MinimumDistance(toUpdate) or distance > MaximumDistance(toUpdate) then
					continue
				end
			end

			local propertySequences: std.Map<string, ColorSequence | NumberSequence> = {}
			local offsets: std.Map<string, number> = {}
			local durations: std.Map<string, number> = {}
			local types: std.Map<string, SequencerType> = {}

			for attributeName, value in toUpdate:GetAttributes() do
				local property = attributeName:match("^Property_(%w+)")
				if property then
					assert(isSequence(value))
					propertySequences[property] = value :: any
					continue
				end

				local offsetForProperty = attributeName:match("^SequencerOffset_(%w+)")
				if offsetForProperty then
					assert(prelude.t.number(value))
					offsets[offsetForProperty] = value :: any
					continue
				end

				local durationForProperty = attributeName:match("^SequencerDuration_(%w+)")
				if durationForProperty then
					assert(prelude.isPositiveNumber(value))
					durations[durationForProperty] = value :: any
					continue
				end

				local typeForProperty = attributeName:match("^SequencerType_(%w+)")
				if typeForProperty then
					assert(isSequencerType(value))
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
					local color = std.color.pickTimeInColorSequence(sequence, time)
					local propertyType: ColorSequencerType = (types[property] or "Color3") :: any
					if not isColorSequencerType(propertyType) then
						logger:warn(
							"Expected property",
							property,
							"of Sequencer",
							toUpdate:GetFullName(),
							"to be Color3, ColorSequence, or BrickColor, but got",
							propertyType,
							"instead."
						)
					end
					newValue = if propertyType == "Color3"
						then color
						elseif propertyType == "ColorSequence" then ColorSequence.new(color)
						elseif propertyType == "BrickColor" then BrickColor.new(color)
						else std.never()
				elseif typeof(sequence) == "NumberSequence" then
					local num = std.math.pickTimeInNumberSequence(sequence, time)
					local propertyType: NumberSequencerType = (types[property] or "number") :: any
					if not isNumberSequencerType(propertyType) then
						logger:warn(
							"Expected property",
							property,
							"of Sequencer",
							toUpdate:GetFullName(),
							"to be number, NumberSequence, or NumberRange, but got",
							propertyType,
							"instead."
						)
					end
					newValue = if propertyType == "number"
						then num
						elseif propertyType == "NumberSequence" then NumberSequence.new(num)
						elseif propertyType == "NumberRange" then NumberRange.new(num)
						else std.never()
				end

				local setSuccess = pcall(setPropertyUnsafe, toUpdate, property, newValue)
				if not setSuccess then
					-- TODO: more helpful error handling
					logger:warn("Cannot update property", property, "of Sequencer", toUpdate:GetFullName())
				end
			end
		end
	end)
end

return self
