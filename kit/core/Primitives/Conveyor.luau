--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--[=[
    @class Conveyor
    @tag KitObjectTag
    Conveyors speeds contacting objects facing it's direction.
]=]
local self = {} :: std.KitScript
self.implements = { KitScript = true }

--[=[
    @prop Speed number
    @within Conveyor
    The speed in studs per second that objects move along the conveyor.
]=]
local Speed = prelude.attribute("Speed", prelude.isPositiveNumber, 0)
--[=[
    @prop SynchronizeConveyorBeams boolean
    @within Conveyor
    If true, the conveyor will update all Beam objects named "ConveyorBeam" to
    move at the same pace as the `Speed` attribute.
]=]
local SynchronizeConveyorBeams = prelude.attribute("SynchronizeConveyorBeams", prelude.isBoolean, true)

function self:run(kit: std.Kit)
	local Conveyor = kit:tag("Conveyor", prelude.isBasePart)

	kit:onPhysics(function(trove, dt)
		debug.profilebegin("Conveyor")
		local alreadySynchronized: std.Set<Instance> = {}
		for _, conveyor in Conveyor:instances() do
			local speed: number = prelude.Enabled(conveyor) and Speed(conveyor) or 0
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed
			if SynchronizeConveyorBeams(conveyor) then
				for _, beam in (conveyor:GetDescendants() :: any) :: { Beam } do
					if not alreadySynchronized[beam] then
						if beam.Name == "ConveyorBeam" and beam.ClassName == "Beam" then
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
end

return self
