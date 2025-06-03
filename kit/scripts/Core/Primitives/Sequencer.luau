--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type ColorSequencerType = "Color3" | "ColorSequence" | "BrickColor"
type NumberSequencerType = "number" | "NumberSequence" | "NumberRange"
type SequencerType = ColorSequencerType | NumberSequencerType

local MinimumDistance = prelude.Attribute("MinimumDistance", prelude.isPositiveNumber, -math.huge)
local MaximumDistance = prelude.Attribute("MaximumDistance", prelude.isPositiveNumber, 100)

local logger = prelude.createLogger("Sequencer")
local isSequence = prelude.t.union(prelude.t.ColorSequence, prelude.t.NumberSequence)
local isColorSequencerType: std.check<SequencerType> = prelude.t.literal("Color3", "ColorSequence", "BrickColor")
local isNumberSequencerType: std.check<SequencerType> = prelude.t.literal("number", "NumberSequence", "NumberRange")
local isSequencerType: std.check<SequencerType> = prelude.t.union(isColorSequencerType, isNumberSequencerType)

local Sequencer = {}
type Self = typeof(Sequencer)
Sequencer.implements = { KitScript = true }

Sequencer.Property = prelude.ManyAttribute("Property", isSequence)
Sequencer.SequencerOffset = prelude.ManyAttribute("SequencerOffset", prelude.t.number)
Sequencer.SequencerDuration = prelude.ManyAttribute("SequencerDuration", prelude.isPositiveNumber)
Sequencer.SequencerType = prelude.ManyAttribute("SequencerType", isSequencerType)

local function setPropertyUnsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

function Sequencer.run(self: Self, kit: std.Kit)
	local tag = kit:tag("Sequencer")
	local localPlayer = Players.LocalPlayer

	kit:onRender(function()
		local loadedLifetime = kit:loadedLifetime()
		for _, toUpdate in tag:instances() do
			if not prelude.Enabled(toUpdate) then
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

			local propertySequences = self.Property(toUpdate)
			local offsets = self.SequencerOffset(toUpdate)
			local durations = self.SequencerDuration(toUpdate)
			local types: std.Map<string, SequencerType> = self.SequencerType(toUpdate) :: any

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

return Sequencer
