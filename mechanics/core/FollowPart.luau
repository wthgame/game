local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type FollowMode = "LookAt" | "RotationOf" | "MoveTo" | "PivotTo" | "None"
type FollowTarget = "Character" | "Mouse" | "Camera" | "None"

type FollowPartAttributes = {
	Enabled: boolean,
	FollowMode: FollowMode,
	FollowTarget: FollowTarget,
	-- TODO: these are not implemented
	UseRelativeTransform: boolean,
	XAxis: boolean,
	YAxis: boolean,
	ZAxis: boolean,
	Lerp: boolean,
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
		-- local raycast = Workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * MAX_RAY_LENGTH)
		if raycast then
			return CFrame.new(raycast.Position)
		end
	end

	if target == "Camera" then
		return Workspace.CurrentCamera.CFrame
	end

	return nil
end

local function initDamageParts(wth: utils.WTH)
	local FollowPart = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "FollowPart",
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
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			FollowMode = utils.t.literal("LookAt", "RotationOf", "MoveTo", "PivotTo", "None"),
			FollowTarget = utils.t.literal("Character", "Mouse", "Camera", "None"),
			UseRelativeTransform = utils.t.boolean,
			XAxis = utils.t.boolean,
			YAxis = utils.t.boolean,
			ZAxis = utils.t.boolean,
			Lerp = utils.t.boolean,
		},
	} :: utils.Mechanic<PVInstance, FollowPartAttributes>

	function FollowPart:kitLoaded(trove, kit)
		-- TODO: maybe a Mechanic:preRender(trove, kit)?
		trove:add(RunService.PreRender:Connect(function(dt)
			debug.profilebegin("FollowPart")
			local instances = self:instances()

			local params = RaycastParams.new()
			params:AddToFilter(CollectionService:GetTagged("FollowMousePart"))
			params.FilterType = Enum.RaycastFilterType.Exclude

			for _, pv in instances do
				local enabled: FollowTarget = self:attribute(pv, "Enabled")
				local target: FollowTarget = self:attribute(pv, "FollowTarget")
				local mode: FollowMode = self:attribute(pv, "FollowMode")

				if target == "Mouse" then
					pv:AddTag("FollowMousePart")
				else
					pv:RemoveTag("FollowMousePart")
				end

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
					elseif mode == "MoveTo" then
						newCFrame = CFrame.new(targetCFrame.Position) * pv:GetPivot().Rotation
					elseif mode == "PivotTo" then
						newCFrame = targetCFrame
					end

					local lerp = self:attribute(pv, "Lerp")
					if lerp then
						pv:PivotTo(pv:GetPivot():Lerp(newCFrame, math.max(dt, 1)))
					else
						pv:PivotTo(newCFrame)
					end
				end
			end
			debug.profileend()
		end))
	end

	wth.registerMechanic(FollowPart)
end

return initDamageParts
