--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type FollowCharacterPartsAttributes = {
	Mode: "Move" | "Align" | "Pivot" | "LookAt",
}

local self = {} :: utils.Mechanic
self.type = "Mechanic"
self.name = "FollowCharacterParts"

-- TODO: Lerp and LerpSmoothness attributes
-- TODO: Persistant attribute and cull throttle
-- FIXME: Align and Rotate mode is tweaking
function self.attach(wth)
	local FollowCharacterParts: utils.Entity<Instance> = wth.createMechanicTag("FollowCharacterParts")
	local FollowCharacterPartsAttributes: utils.Entity<FollowCharacterPartsAttributes> = wth.createMechanicAttributes(
		FollowCharacterParts,
		{
			Mode = utils.t.literalList({ "Move", "Align", "Pivot", "LookAt" }),
		},
		{
			Mode = "Move",
		}
	)

	local queryFollowCharacterParts = wth.world:query(FollowCharacterParts):cached()

	local enabled = utils.InstanceAttributeReconciler(utils.t.boolean, true, "Enabled")
	-- TODO: implement
	local lerp = utils.InstanceAttributeReconciler(utils.t.boolean, true, "Lerp")
	local lerpSmoothness = utils.InstanceAttributeReconciler(utils.t.numberPositive, 40, "LerpSmoothness")
	local persitent = utils.InstanceAttributeReconciler(utils.t.boolean, true, "Persistent")

	local function updateFollowCharacterParts()
		local root = utils.getMaybeHumanoidRootPart()

		if not root then
			return
		end

		for entity, parts in queryFollowCharacterParts:iter() do
			local attributes = wth.world:get(entity, FollowCharacterPartsAttributes)
			if not attributes then
				continue
			end

			-- for _, part in parts:GetDescendants() do
			-- 	if not enabled:reconcile(part) then
			-- 		continue
			-- 	end

			-- 	if attributes.Mode == "Move" then
			-- 	    if part:IsA("BasePart") then
			-- 					if lerp()
			-- 					end
			-- 	elseif attributes.Mode == "Align" then
			-- 	elseif attributes.Mode == "Pivot" then
			-- 	elseif attributes.Mode == "LookAt" then
			-- 	end
			-- end

			if attributes.Mode == "Move" then
				local rootPosition = CFrame.new(root.Position.X, root.Position.Y, root.Position.Z)
				for _, part in parts:GetDescendants() do
					if not enabled:reconcile(part) then
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
					if not enabled:reconcile(part) then
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
					if not enabled:reconcile(part) then
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
					if not enabled:reconcile(part) then
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

	wth.pushSystems(updateFollowCharacterParts)
end

return self
