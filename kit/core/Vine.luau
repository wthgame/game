--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

export type VineInstance = BasePart & {
	Constraint: Constraint?,
	Top: BasePart,
}

local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
local KeepVelocity = utils.attribute("KeepVelocity", utils.t.boolean, true)
local AllowJumpDismount = utils.attribute("AllowJumpDismount", utils.t.boolean, true)
local JumpOnDismount = utils.attribute("JumpOnDismount", utils.t.boolean, true)
local PlayGrabSound = utils.attribute("PlayGrabSound", utils.t.boolean, true)
local PlayJumpSound = utils.attribute("PlayJumpSound", utils.t.boolean, true)

local debounced: utils.Set<VineInstance> = {}

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

local function createHandle(trove: utils.Trove)
	local handle = trove:add(Instance.new("Part"))
	handle.Name = "Handle"
	handle.CanCollide = false
	handle.CustomPhysicalProperties = PhysicalProperties.new(10, 0, 0, 1, 1)
	handle.Size = Vector3.new(3, 0.5, 0.5)
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	return handle
end

local function doVine(trove: utils.Trove, vineInstance: VineInstance, activationTrove: utils.Trove)
	if debounced[vineInstance] then
		return
	end
	debounced[vineInstance] = true

	activationTrove:clean()

	local root = utils.getHumanoidRootPart()
	local originalLinearVelocity = root.AssemblyLinearVelocity
	local originalAngularVelocity = root.AssemblyAngularVelocity

	local attachmentTrove = trove:extend()
	local constraint = trove:clone(constraintOf(vineInstance))
	local handle = createHandle(attachmentTrove)
	local attachment0, attachment1 = utils.populateConstraintAttachments(constraint)
	attachmentTrove:add(attachment0)
	attachmentTrove:add(attachment1)

	handle.Color = vineInstance.Color
	handle.CFrame = root.CFrame * CFrame.new(0, 2.6, 0)

	utils.weld(trove, handle, root)
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
		utils.inferAndPlaySound(vineInstance, utils.AUDIO_ASSETS["core/towerSfx/button"], "GrabSound")
	end

	local function dismount()
		attachmentTrove:clean()

		local humanoid = utils.getMaybeHumanoid()
		if humanoid and JumpOnDismount(vineInstance) then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		if PlayJumpSound(vineInstance) then
			utils.inferAndPlaySound(vineInstance, utils.AUDIO_ASSETS["core/towerSfx/jump"], "JumpSound")
		end

		task.delay(Cooldown(vineInstance), function(vineInstance)
			debounced[vineInstance] = nil
			vineInstance.Transparency = 0
			utils.connectActivation(trove, vineInstance, doVine)
		end, vineInstance)
	end

	if AllowJumpDismount(vineInstance) then
		attachmentTrove:connect(UserInputService.JumpRequest, dismount)
	end
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Vine = kit:tag(
		"Vine",
		utils.t.instanceIsA("BasePart", {
			Constraint = utils.t.optional(utils.t.instanceIsA("Constraint")),
			Top = utils.isBasePart,
		}) :: utils.check<VineInstance>
	)
	Vine:onActivated(doVine)
end

return self
