--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type ConveyorAttributes = {
	Speed: number,
	SynchronizeConveyorBeams: boolean,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Conveyor"

function mech:init(wth)
	local Conveyor: utils.Entity<BasePart> = wth:useTag("Conveyor", utils.t.instanceIsA("BasePart"))
	print(Conveyor)
	local Speed = wth:useAttribute("Speed", Conveyor, utils.t.numberPositive, 16)
	local SynchronizeConveyorBeams = wth:useAttribute("SynchronizeConveyorBeams", Conveyor, utils.t.boolean, true)

	local queryConveyors = wth.world:query(Conveyor, Speed, SynchronizeConveyorBeams):cached()

	local function updateConveyors()
		local alreadySynchronized = {}

		for entity, conveyor, speed, sync in queryConveyors:iter() do
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed

			if sync then
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

	wth:schedule(updateConveyors)
end

return mech
