--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: implement below for mobile
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475439884042422
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475483563528202

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

type FollowMode = "LookAt" | "RotationOf" | "PositionOf" | "PivotOf" | "None"
type FollowTarget = "Character" | "Mouse" | "Camera" | "None"

local MAX_RAY_LENGTH = 10_000
local mouse = Players.LocalPlayer:GetMouse()

local FollowMode =
	utils.attribute("FollowMode", utils.t.literal("LookAt", "RotationOf", "PositionOf", "PivotOf", "None"), "None")
local FollowTarget = utils.attribute("FollowTarget", utils.t.literal("Character", "Mouse", "Camera", "None"), "None")
-- local UseRelativeTransform = utils.attribute("UseRelativeTransform", utils.t.boolean, false)
-- local XAxis = utils.attribute("XAxis", utils.t.boolean, true)
-- local YAxis = utils.attribute("YAxis", utils.t.boolean, true)
-- local ZAxis = utils.attribute("ZAxis", utils.t.boolean, true)
local Lerp = utils.attribute("Lerp", utils.t.boolean, false)
local LerpAlpha = utils.attribute("LerpAlpha", utils.t.numberPositive, 1)

local function getTargetCFrame(target: FollowTarget, params: RaycastParams): CFrame?
	if target == "Character" then
		local root = utils.getLocalHumanoidRootPart()
		if root then
			return root.CFrame
		end
	end

	if target == "Mouse" then
		local raycast = Workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * MAX_RAY_LENGTH, params)
		if raycast then
			return CFrame.new(raycast.Position)
		end
	end

	if target == "Camera" then
		return Workspace.CurrentCamera.CFrame
	end

	return nil
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Follower = kit:tag("Follower", utils.t.instanceIsA("PVInstance") :: utils.check<PVInstance>)

	kit:onRender(function(trove, dt)
		debug.profilebegin("Follower")

		local params = RaycastParams.new()
		params:AddToFilter(CollectionService:GetTagged("MouseFollowerIgnored"))
		params.FilterType = Enum.RaycastFilterType.Exclude

		for _, pv in Follower:instances() do
			local mode: FollowMode = FollowMode(pv)
			local target: FollowTarget = FollowTarget(pv)

			if not utils.isActive(pv) or mode == "None" or target == "None" then
				continue
			end

			local targetCFrame = getTargetCFrame(target, params)
			if targetCFrame then
				local newCFrame: CFrame
				if mode == "LookAt" then
					newCFrame = CFrame.lookAt(pv:GetPivot().Position, targetCFrame.Position)
				elseif mode == "RotationOf" then
					newCFrame = CFrame.new(pv:GetPivot().Position) * targetCFrame.Rotation
				elseif mode == "PositionOf" then
					newCFrame = CFrame.new(targetCFrame.Position) * pv:GetPivot().Rotation
				elseif mode == "PivotOf" then
					newCFrame = targetCFrame
				else
					error("Invalid FollowMode (unreachable?)")
				end

				local lerp = Lerp(pv)
				if lerp then
					pv:PivotTo(pv:GetPivot():Lerp(newCFrame, 1 / LerpAlpha(pv)))
				else
					pv:PivotTo(newCFrame)
				end
			end
		end
		debug.profileend()
	end)
end

return self
