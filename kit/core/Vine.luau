--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

export type VineInstance = BasePart & {
	Constraint: Constraint?,
	Top: BasePart,
}

local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
local KeepVelocity = prelude.attribute("KeepVelocity", prelude.t.boolean, true)
local AllowJumpDismount = prelude.attribute("AllowJumpDismount", prelude.t.boolean, true)
local JumpOnDismount = prelude.attribute("JumpOnDismount", prelude.t.boolean, true)
local PlayGrabSound = prelude.attribute("PlayGrabSound", prelude.t.boolean, true)
local PlayJumpSound = prelude.attribute("PlayJumpSound", prelude.t.boolean, true)

local debounced: std.Set<VineInstance> = {}

local function constraintOf(vineInstance: VineInstance)
	local constraint = vineInstance.Constraint
	if constraint then
		if constraint:IsA("Constraint") then
			return constraint
		end
		constraint.Name ..= "_FAKE"
	end
	local rope = Instance.new("RopeConstraint")
	rope.Name = "Constraint"
	rope.Parent = vineInstance
	return rope
end

local function createHandle(trove: std.Trove)
	local handle = trove:add(Instance.new("Part"))
	handle.Name = "Handle"
	handle.CanCollide = false
	handle.CustomPhysicalProperties = PhysicalProperties.new(10, 0, 0, 1, 1)
	handle.Size = Vector3.new(3, 0.5, 0.5)
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	return handle
end

local function doVine(trove: std.Trove, vineInstance: VineInstance, activationTrove: std.Trove)
	if debounced[vineInstance] then
		return
	end
	debounced[vineInstance] = true

	activationTrove:clean()

	local root = prelude.getHumanoidRootPart()
	local originalLinearVelocity = root.AssemblyLinearVelocity
	local originalAngularVelocity = root.AssemblyAngularVelocity

	local attachmentTrove = trove:extend()
	local constraint = trove:clone(constraintOf(vineInstance))
	local handle = createHandle(attachmentTrove)
	local attachment0, attachment1 = std.physics.populateConstraintAttachments(constraint)
	attachmentTrove:add(attachment0)
	attachmentTrove:add(attachment1)

	handle.Color = vineInstance.Color
	handle.CFrame = root.CFrame * CFrame.new(0, 2.6, 0)

	std.physics.weld(trove, handle, root)
	handle.Parent = vineInstance

	constraint.Visible = true
	constraint.Color = vineInstance.BrickColor
	constraint.Parent = vineInstance.Top

	attachment0.Parent = vineInstance.Top
	attachment1.Parent = handle

	vineInstance.Transparency = 1

	if KeepVelocity(vineInstance) then
		root.AssemblyLinearVelocity = originalLinearVelocity
		root.AssemblyAngularVelocity = originalAngularVelocity
	end

	if PlayGrabSound(vineInstance) then
		prelude.inferAndPlaySound(vineInstance, prelude.AUDIO_ASSETS["core/towerSfx/vineGrab"], "GrabSound")
	end

	local function dismount()
		attachmentTrove:clean()

		local humanoid = std.character.getMaybeHumanoid()
		if humanoid and JumpOnDismount(vineInstance) then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		if PlayJumpSound(vineInstance) then
			prelude.inferAndPlaySound(vineInstance, prelude.AUDIO_ASSETS["core/towerSfx/jump"], "JumpSound")
		end

		task.delay(Cooldown(vineInstance), function(vineInstance)
			debounced[vineInstance] = nil
			vineInstance.Transparency = 0
			prelude.connectActivation(trove, vineInstance, doVine)
		end, vineInstance)
	end

	if AllowJumpDismount(vineInstance) then
		attachmentTrove:connect(UserInputService.JumpRequest, dismount)
	end
end

local self = {} :: std.KitScript
self.type = "KitScript"

function self:run(kit: std.Kit)
	local Vine = kit:tag(
		"Vine",
		prelude.t.instanceIsA("BasePart", {
			Constraint = prelude.t.optional(prelude.t.instanceIsA("Constraint")),
			Top = prelude.isBasePart,
		}) :: std.check<VineInstance>
	)
	Vine:onActivated(doVine)
end

return self
