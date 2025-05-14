--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local Speed = prelude.attribute("Speed", prelude.isPositiveNumber, 0)
local SynchronizeConveyorBeams = prelude.attribute("SynchronizeConveyorBeams", prelude.isBoolean, true)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Conveyor = kit:tag("Conveyor", prelude.isBasePart)

	kit:onPhysics(function(trove, dt)
		debug.profilebegin("Conveyor")
		local alreadySynchronized: utils.Set<Instance> = {}
		for _, conveyor in Conveyor:instances() do
			local speed: number = prelude.Active(conveyor) and Speed(conveyor) or 0
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed
			if SynchronizeConveyorBeams(conveyor) then
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
		debug.profileend()
	end)
end

return self
