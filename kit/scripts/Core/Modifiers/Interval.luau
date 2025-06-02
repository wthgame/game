--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @class Interval
--- @tag KitObject
---
--- Toggle properties based on time intervals.
local Interval = {}
type Self = typeof(Interval)
Interval.implements = { KitScript = true }

Interval.EnabledTime = prelude.attribute("EnabledTime", prelude.isPositiveNumber, 1)
Interval.DisabledTime = prelude.attribute("DisabledTime", prelude.isPositiveNumber, 1)
Interval.TimeOffset = prelude.attribute("TimeOffset", prelude.isPositiveNumber, 0)
Interval.Synchronized = prelude.attribute("Synchronized", prelude.isBoolean, true)
Interval.SetEnabled = prelude.attribute("SetEnabled", prelude.isBoolean, false)
Interval.Indicate = prelude.attribute("Indicate", prelude.isBoolean, true)
Interval.IndicateBy = prelude.attribute("IndicateBy", prelude.isPositiveNumber, 0.5)

local function setPropertyUnsafe(instance: Instance, property: string, value: unknown)
	(instance :: any)[property] = value
end

function Interval.run(self: Self, kit: std.Kit)
	local tag = kit:tag("Interval")

	kit:onTick(function(trove: std.Trove, dt: number)
		local loadedLifetime = kit:loadedLifetime()
		for _, interval in tag:instances() do
			local setEnabled = self.SetEnabled(interval)
			if not setEnabled and not prelude.Enabled(interval) then
				continue
			end

			local enabledTime, disabledTime = self.EnabledTime(interval), self.DisabledTime(interval)
			local cycleTime = enabledTime + disabledTime
			-- TODO: implement unsynchronized time
			local cycleProgress = if self.Synchronized(interval)
				then (loadedLifetime + self.TimeOffset(interval)) % cycleTime
				else 0
			local enabled = cycleProgress < enabledTime

			if setEnabled then
				prelude.Enabled:set(interval, enabled)
			end

			local enabledProps, disabledProps = {}, {}
			for attributeName, value in interval:GetAttributes() do
				local enabledProp = attributeName:match("^Enabled_(%w+)")
				if enabledProp then
					enabledProps[enabledProp] = value :: any
					continue
				end

				local disabledProp = attributeName:match("^Disabled_(%w+)")
				if disabledProp then
					disabledProps[disabledProp] = value :: any
					continue
				end
			end

			if enabled then
				for prop, value in enabledProps do
					local setSuccess = pcall(setPropertyUnsafe, interval, prop, value)
					if not setSuccess then
						-- TODO: better error handling
					end
				end

				continue
			end

			for prop, value in disabledProps do
				local setSuccess = pcall(setPropertyUnsafe, interval, prop, value)
				if not setSuccess then
					-- TODO: better error handling
				end
			end
		end
	end)
end

return Interval
