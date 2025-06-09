--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local TweenMoverId = prelude.Attribute("TweenMoverId", prelude.isString)
local TweenMoverIndex = prelude.Attribute("TweenMoverIndex", prelude.t.integer)
local Interval = prelude.Attribute("Interval", prelude.isPositiveNumber)

local idToDestination: std.MapSet<string, BasePart> = std.collections.MapSet()

local TweenMover = {}
TweenMover.implements = { KitScript = true }

local function destinationsOfId(id: string)
	local destinations = idToDestination:get(id)
	local sorted = {}
	for d in destinations do
		local index = TweenMoverIndex(d) or tonumber(d.Name)
		assert(index, `Unexpected TweenMoverPosition {d:GetFullName()}`)
		sorted[index] = d
	end
	return sorted
end

function TweenMover:run(kit: std.Kit)
	local destination = kit:tag("TweenMoverDestination", prelude.isBasePart)

	kit:tag("TweenMover", prelude.t.instanceIsA("BasePart")):onLoaded(function(trove, mover)
		local currentIndex = 1
		local stop = false
		trove:add(function()
			stop = true
		end)

		while true do
			if stop then
				return
			end

			local interval = Interval(mover)

			-- TODO: check for nonsequential keys
			local id = TweenMoverId(mover)
			if id then
				local positions = destinationsOfId(id)
				currentIndex += 1
				if currentIndex > #positions then
					currentIndex = 1
				end
				local currentPosition = positions[currentIndex]
				if currentPosition then
					prelude.tweenMaybeInstant(
						mover,
						{ CFrame = currentPosition.CFrame },
						prelude.tweenConfigFromAttributes(mover, "Transition")
					)
					local nextPosition = positions[currentIndex + 1] or positions[1]
					local nextInterval = Interval(nextPosition)
					if nextInterval then
						interval = nextInterval
					end
				end
			end
			if interval then
				task.wait(interval)
			else
				RunService.PostSimulation:Wait()
			end
		end
	end)

	destination:onLoaded(function(trove, destination)
		local id = TweenMoverId(destination)
		if id then
			idToDestination:add(id, destination)
		end
	end)
end

return TweenMover
