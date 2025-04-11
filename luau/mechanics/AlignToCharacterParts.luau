--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type AlignToCharacterPartsAttributes = {
	Mode: "Move" | "Align" | "Pivot" | "LookAt",
}

local self = {} :: utils.Mechanic
self.type = "Mechanic"
self.name = "AlignToCharacterParts"

function self.attach(wth)
	local AlignToCharacterParts: utils.Entity<Instance> = wth.createMechanicTag("AlignToCharacterParts")
	local AlignToCharacterPartsAttributes: utils.Entity<AlignToCharacterPartsAttributes> = wth.createMechanicAttributes(
		AlignToCharacterParts,
		{
			Mode = utils.t.literalList({ "Move", "Align", "Pivot", "LookAt" }),
		},
		{
			Mode = "Move",
		}
	)

	local queryAlignToCharacterParts = wth.world:query(AlignToCharacterParts):cached()

	local function updateAlignToCharacterParts()
		local root = utils.getMaybeHumanoidRootPart()

		if not root then
			return
		end

		for entity, parts in queryAlignToCharacterParts:iter() do
			local attributes = wth.world:get(entity, AlignToCharacterPartsAttributes)
			if not attributes then
				continue
			end

			if attributes.Mode == "Move" then
				local rootPosition = CFrame.new(root.Position.X, root.Position.Y, root.Position.Z)
				for _, part in parts:GetDescendants() do
					if part:GetAttribute("Enabled") == false then
						continue
					end

					if part:IsA("BasePart") then
						part:PivotTo(rootPosition * part.CFrame.Rotation)
					elseif part:IsA("Model") then
						local primaryPart = part.PrimaryPart
						if not primaryPart then
							continue
						end
						part:PivotTo(rootPosition * primaryPart.CFrame.Rotation)
					end
				end
			elseif attributes.Mode == "Align" then
				local rootRotation = root.CFrame.Rotation
				for _, part in parts:GetDescendants() do
					if part:GetAttribute("Enabled") == false then
						continue
					end

					if part:IsA("BasePart") then
						part:PivotTo(CFrame.new(part.Position.X, part.Position.Y, part.Position.Z) * rootRotation)
					elseif part:IsA("Model") then
						local primaryPart = part.PrimaryPart
						if not primaryPart then
							continue
						end
						part:PivotTo(
							CFrame.new(primaryPart.Position.X, primaryPart.Position.Y, primaryPart.Position.Z)
								* rootRotation
						)
					end
				end
			elseif attributes.Mode == "Pivot" then
				for _, part in parts:GetDescendants() do
					if part:GetAttribute("Enabled") == false then
						continue
					end

					if part:IsA("BasePart") then
						part:PivotTo(root.CFrame)
					elseif part:IsA("Model") then
						local primaryPart = part.PrimaryPart
						if not primaryPart then
							continue
						end
						part:PivotTo(root.CFrame)
					end
				end
			elseif attributes.Mode == "LookAt" then
				local rootPosition = root.Position
				for _, part in parts:GetDescendants() do
					if part:GetAttribute("Enabled") == false then
						continue
					end

					if part:IsA("BasePart") then
						part:PivotTo(CFrame.lookAt(part.Position, rootPosition))
					elseif part:IsA("Model") then
						local primaryPart = part.PrimaryPart
						if not primaryPart then
							continue
						end
						part:PivotTo(CFrame.lookAt(primaryPart.Position, rootPosition))
					end
				end
			end
		end
	end

	wth.pushSystems(updateAlignToCharacterParts)
end

return self
