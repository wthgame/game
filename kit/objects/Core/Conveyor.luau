--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("NEW_KitStd"))
local prelude = std.prelude

--[=[
    @class Conveyor
    @tag KitObject
    Conveyors speeds contacting objects facing it's direction.
]=]
local Conveyor = {}
Conveyor.tag = prelude.observeTag("Conveyor", prelude.isBasePart)

--[=[
    @prop Speed number
    @within Conveyor
    The speed in studs per second that objects move along the conveyor.
]=]
Conveyor.Speed = prelude.attribute("Speed", prelude.isPositiveNumber, 0)

--[=[
    @prop SynchronizeConveyorBeams boolean
    @within Conveyor
    If true, the conveyor will update all Beam objects named "ConveyorBeam" to
    move at the same pace as the `Speed` attribute.
]=]
Conveyor.SynchronizeConveyorBeams = prelude.attribute("SynchronizeConveyorBeams", prelude.isBoolean, true)

Conveyor.tag:onPreSimulation(function(trove, dt)
	debug.profilebegin("Conveyor")
	local alreadySynchronized: std.Set<Instance> = {}
	for _, con in Conveyor.tag:get() do
		-- local speed: number = prelude.Active(conveyor) and Conveyor.Speed(conveyor) or 0
		local speed: number = Conveyor.Speed(con)
		con.AssemblyLinearVelocity = con.CFrame.LookVector * speed
		if Conveyor.SynchronizeConveyorBeams(con) then
			for _, beam in con:GetDescendants() do
				if not alreadySynchronized[beam] then
					if beam.Name == "ConveyorBeam" and beam:IsA("Beam") then
						beam.TextureSpeed = speed / beam.TextureLength
					end
					alreadySynchronized[beam] = true
				end
			end
		end
	end
	table.clear(alreadySynchronized)
	debug.profileend()
end)

return Conveyor
