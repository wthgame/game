--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type ConveyorAttributes = {
	Speed: number,
	SynchronizeConveyorBeams: boolean,
}

local self = {} :: utils.Mechanic
self.type = "Mechanic"
self.name = "Conveyor"

function self.attach(wth)
	local Conveyor: utils.Entity<BasePart> = wth.createMechanicTag("Conveyor", utils.t.instanceIsA("BasePart"))

	local ConveyorAttributes: utils.Entity<ConveyorAttributes> = wth.createMechanicAttributes(Conveyor, {
		Speed = utils.t.number,
		SynchronizeConveyorBeams = utils.t.boolean,
	}, {
		Speed = 16,
		SynchronizeConveyorBeams = true,
	})

	local queryConveyors = wth.world:query(Conveyor):cached()

	local function updateConveyors()
		local alreadySynchronized = {}

		for entity, conveyor in queryConveyors:iter() do
			local attributes = wth.world:get(entity, ConveyorAttributes)
			if not attributes then
				continue
			end

			local speed = attributes.Speed
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed

			if attributes.SynchronizeConveyorBeams then
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

	wth.pushSystems(updateConveyors)
end

return self
