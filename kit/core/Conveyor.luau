--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Speed = utils.attribute("Speed", utils.t.numberPositive, 0)
local SynchronizeConveyorBeams = utils.attribute("SynchronizeConveyorBeams", utils.t.boolean, true)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Conveyor = kit:tag("Conveyor", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	kit:onPhysics(function(trove, dt)
		local alreadySynchronized: utils.Set<Instance> = {}

		for _, conveyor in Conveyor:instances() do
			local speed: number = utils.Active(conveyor) and Speed(conveyor) or 0
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
	end)
end

return self
