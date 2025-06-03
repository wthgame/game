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

Interval.EnabledTime = prelude.Attribute("EnabledTime", prelude.isPositiveNumber, 1)
Interval.DisabledTime = prelude.Attribute("DisabledTime", prelude.isPositiveNumber, 1)
Interval.TimeOffset = prelude.Attribute("TimeOffset", prelude.isPositiveNumber, 0)
Interval.Synchronized = prelude.Attribute("Synchronized", prelude.isBoolean, true)
Interval.SetEnabled = prelude.Attribute("SetEnabled", prelude.isBoolean, false)
Interval.Indicate = prelude.Attribute("Indicate", prelude.isBoolean, true)
Interval.IndicateBy = prelude.Attribute("IndicateBy", prelude.isPositiveNumber, 0.5)

Interval.EnabledProperties = prelude.ManyAttribute("Enabled", prelude.t.any)
Interval.DisabledProperties = prelude.ManyAttribute("Disabled", prelude.t.any)

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

			local enabledProps, disabledProps = self.EnabledProperties(interval), self.DisabledProperties(interval)

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
