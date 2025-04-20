--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type ConveyorAttributes = {
	Enabled: boolean,
	Speed: number,
	SynchronizeConveyorBeams: boolean,
}

local function init(wth: utils.WTH)
	local Conveyor = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Conveyor",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Enabled = true,
			Speed = 0,
			SynchronizeConveyorBeams = true,
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			Speed = utils.t.numberPositive,
			SynchronizeConveyorBeams = utils.t.boolean,
		},
	} :: utils.Mechanic<BasePart, ConveyorAttributes>

	function Conveyor:physicStepped(trove, dt, kit)
		local alreadySynchronized = {}

		for _, conveyor in self:instances() do
			local speed: number = self:attribute(conveyor, "Enabled") and self:attribute(conveyor, "Speed") or 0
			conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * speed

			if self:attribute(conveyor, "SynchronizeConveyorBeams") then
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

	wth.registerMechanic(Conveyor)
end

return init
