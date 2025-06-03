--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: implement below for mobile
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475439884042422
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475483563528202

-- local CollectionService = game:GetService("CollectionService")
-- local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type FollowMode = "LookAt" | "RotationOf" | "PositionOf" | "PivotOf" | "None"
type FollowTarget = "Character" | "Mouse" | "Camera" | "None"

-- local MAX_RAY_LENGTH = 2_000
-- local mouse = Players.LocalPlayer:GetMouse()

local FollowMode =
	prelude.Attribute("FollowMode", prelude.t.literal("LookAt", "RotationOf", "PositionOf", "PivotOf", "None"), "None")
local FollowTarget =
	prelude.Attribute("FollowTarget", prelude.t.literal("Character", "Mouse", "Camera", "None"), "None")
-- local UseRelativeTransform = prelude.Attribute("UseRelativeTransform", prelude.isBoolean, false)
-- local XAxis = prelude.Attribute("XAxis", prelude.isBoolean, true)
-- local YAxis = prelude.Attribute("YAxis", prelude.isBoolean, true)
-- local ZAxis = prelude.Attribute("ZAxis", prelude.isBoolean, true)
local Lerp = prelude.Attribute("Lerp", prelude.isBoolean, false)
local LerpAlpha = prelude.Attribute("LerpAlpha", prelude.isPositiveNumber, 1)

-- TODO: mouse is too laggy
-- local function getTargetCFrame(target: FollowTarget, params: RaycastParams): CFrame?
local function getTargetCFrame(target: FollowTarget): CFrame?
	if target == "Character" then
		local root = prelude.getHumanoidRootPart()
		if root then
			return root.CFrame
		end
	end

	-- if target == "Mouse" then
	-- 	local raycast = Workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * MAX_RAY_LENGTH, params)
	-- 	if raycast then
	-- 		return CFrame.new(raycast.Position)
	-- 	end
	-- end

	if target == "Camera" then
		return Workspace.CurrentCamera.CFrame
	end

	return nil
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Follower = kit:tag("Follower", prelude.isBasePart)

	local function updateFollower(trove: std.Trove, dt: number)
		debug.profilebegin("Follower")

		-- local params = RaycastParams.new()
		-- params:AddToFilter(CollectionService:GetTagged("MouseFollowerIgnored"))
		-- params.FilterType = Enum.RaycastFilterType.Exclude

		local bulkInstances, bulkCFrames = {}, {}

		for _, part in Follower:instances() do
			local mode: FollowMode = FollowMode(part)
			local target: FollowTarget = FollowTarget(part)

			if not prelude.Enabled(part) or mode == "None" or target == "None" then
				continue
			end

			-- local targetCFrame = getTargetCFrame(target, params)
			local targetCFrame = getTargetCFrame(target)
			if targetCFrame then
				local newCFrame: CFrame
				if mode == "LookAt" then
					newCFrame = CFrame.lookAt(part:GetPivot().Position, targetCFrame.Position)
				elseif mode == "RotationOf" then
					newCFrame = CFrame.new(part:GetPivot().Position) * targetCFrame.Rotation
				elseif mode == "PositionOf" then
					newCFrame = CFrame.new(targetCFrame.Position) * part:GetPivot().Rotation
				elseif mode == "PivotOf" then
					newCFrame = targetCFrame
				else
					std.never(mode)
				end

				table.insert(bulkInstances, part)
				table.insert(
					bulkCFrames,
					if Lerp(part) then part.CFrame:Lerp(newCFrame, 1 / LerpAlpha(part)) else newCFrame
				)
			end
		end

		Workspace:BulkMoveTo(bulkInstances, bulkCFrames)
		debug.profileend()
	end

	kit:onPhysics(updateFollower)
	kit:onTick(updateFollower)
end

return self
