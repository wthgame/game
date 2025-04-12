--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wth = require(ReplicatedStorage:WaitForChild("Lib"))

type Self = wth.Mechanic<{
	Conveyor: wth.Entity<BasePart>,
	Speed: (instance: Instance) -> number,
	SynchronizeConveyorBeams: (instance: Instance) -> boolean,
}>

type ConveyorAttributes = {
	Speed: number,
	SynchronizeConveyorBeams: boolean,
}

local mech = {} :: Self
mech.type = "Mechanic"
mech.name = "Conveyor"

mech.Conveyor = wth.trackCollectionServiceTag("Conveyor", wth.t.instanceIsA("BasePart"))
mech.Speed = wth.createAttributeReconciler("Speed", wth.t.numberPositive, 16)
mech.SynchronizeConveyorBeams = wth.createAttributeReconciler("SynchronizeConveyorBeams", wth.t.boolean, true)

function mech:init(schedule)
	print(self.Conveyor)
	local queryConveyors = wth.world:query(self.Conveyor)

	local function updateConveyors()
		local alreadySynchronized = {}

		for entity, conveyor in queryConveyors:iter() do
			local speed = self.Speed(conveyor)
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed

			if self.SynchronizeConveyorBeams(conveyor) then
				for _, beam in conveyor:GetDescendants() do
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
	end

	schedule(updateConveyors)
end

return mech
