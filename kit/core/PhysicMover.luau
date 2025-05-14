--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

export type PhysicMoverInstance = BasePart & {
	Positions: Instance,
	AlignPosition: AlignPosition,
	AlignOrientation: AlignOrientation,
}

local PhysicMoverId = prelude.attribute("PhysicMoverId", prelude.isString)
local PhysicMoverIndex = prelude.attribute("PhysicMoverIndex", prelude.t.integer)
local Interval = prelude.attribute("Interval", prelude.isPositiveNumber)

local idToDestination: std.MapSet<string, BasePart> = std.collections.MapSet()

local self = {} :: std.KitScript
self.type = "KitScript"

local function destinationsOfId(id: string)
	local destinations = idToDestination:get(id)
	local sorted = {}
	for d in destinations do
		local index = PhysicMoverIndex(d) or tonumber(d.Name)
		assert(index, `Unexpected PhysicMoverPosition {d:GetFullName()}`)
		sorted[index] = d
	end
	return sorted
end

function self:run(kit: std.Kit)
	local PhysicMover = kit:tag(
		"PhysicMover",
		prelude.t.instanceIsA("BasePart", {
			AlignPosition = prelude.t.instanceIsA("AlignPosition"),
			AlignOrientation = prelude.t.instanceIsA("AlignOrientation"),
		}) :: std.check<PhysicMoverInstance>
	)
	local PhysicMoverDestination = kit:tag("PhysicMoverDestination", prelude.isBasePart)
	PhysicMover:onLoaded(function(trove, mover)
		mover.AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		mover.Anchored = false

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
			local id = PhysicMoverId(mover)
			if id then
				local positions = destinationsOfId(id)
				currentIndex += 1
				if currentIndex > #positions then
					currentIndex = 1
				end
				local currentPosition = positions[currentIndex]
				if currentPosition then
					mover.AlignPosition.Position = currentPosition.CFrame.Position
					mover.AlignOrientation.CFrame = currentPosition.CFrame.Rotation
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
	PhysicMoverDestination:onLoaded(function(trove, destination)
		local id = PhysicMoverId(destination)
		if id then
			idToDestination:add(id, destination)
		end
	end)
end

return self
