--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: implement below for mobile
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475439884042422
-- https://discord.com/channels/1303215495557943327/1303215496396673076/1363475483563528202

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type FollowMode = "LookAt" | "RotationOf" | "PositionOf" | "PivotOf" | "None"
type FollowTarget = "Character" | "Mouse" | "Camera" | "None"

type FollowPartAttributes = {
	Enabled: boolean,
	FollowMode: FollowMode,
	FollowTarget: FollowTarget,
	Lerp: boolean,
	LerpAlpha: number,
	-- TODO: these are not implemented
	XAxis: boolean,
	YAxis: boolean,
	ZAxis: boolean,
	UseRelativeTransform: boolean,
}

local MAX_RAY_LENGTH = 10_000
local mouse = Players.LocalPlayer:GetMouse()

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

local function init(wth: utils.WTH)
	local Follower = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Follower",
		instanceCheck = utils.t.instanceIsA("PVInstance"),
		defaultAttributes = {
			Enabled = true,
			FollowMode = "None",
			FollowTarget = "None",
			UseRelativeTransform = false,
			XAxis = true,
			YAxis = true,
			ZAxis = true,
			Lerp = false,
			LerpAlpha = 1,
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			FollowMode = utils.t.literal("LookAt", "RotationOf", "PositionOf", "PivotOf", "None"),
			FollowTarget = utils.t.literal("Character", "Mouse", "Camera", "None"),
			UseRelativeTransform = utils.t.boolean,
			XAxis = utils.t.boolean,
			YAxis = utils.t.boolean,
			ZAxis = utils.t.boolean,
			Lerp = utils.t.boolean,
			LerpAlpha = utils.t.number,
		},
	} :: utils.Mechanic<PVInstance, FollowPartAttributes>

	function Follower:renderStepped(trove, dt, kit)
		debug.profilebegin("Follower")
		local instances = self:instances()

		local params = RaycastParams.new()
		params:AddToFilter(CollectionService:GetTagged("MouseFollowerIgnored"))
		params.FilterType = Enum.RaycastFilterType.Exclude

		for _, pv in instances do
			local enabled: FollowTarget = self:attribute(pv, "Enabled")
			local target: FollowTarget = self:attribute(pv, "FollowTarget")
			local mode: FollowMode = self:attribute(pv, "FollowMode")

			if not enabled or mode == "None" or target == "None" then
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

				local lerp = self:attribute(pv, "Lerp")
				if lerp then
					pv:PivotTo(pv:GetPivot():Lerp(newCFrame, 1 / self:attribute(pv, "LerpAlpha")))
				else
					pv:PivotTo(newCFrame)
				end
			end
		end
		debug.profileend()
	end

	wth.registerMechanic(Follower)
end

return init
