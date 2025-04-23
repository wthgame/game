--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local Speed = utils.attribute("Speed", utils.t.numberPositive, 0)
local SynchronizeConveyorBeams = utils.attribute("SynchronizeConveyorBeams", utils.t.boolean, true)

local function init(wth: utils.WTH)
	local Conveyor = wth:tag("Conveyor", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	wth:onPhysics(function(trove, dt)
		local alreadySynchronized: utils.Set<Instance> = {}

		for _, conveyor in Conveyor:instances() do
			local speed: number = utils.isActive(conveyor) and Speed(conveyor) or 0
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

return init
