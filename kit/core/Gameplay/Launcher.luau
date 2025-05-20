--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type Vector = "Up" | "Right" | "Look" | "Z"

local EmitLauncherParticle = prelude.attribute("EmitLauncherParticle", prelude.isBoolean, true)
local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 1)
local Power = prelude.attribute("Power", prelude.isPositiveNumber, 0)
local MaxForce = prelude.attribute("MaxForce", prelude.isPositiveNumber, math.huge)
local Vector = prelude.attribute("Vector", prelude.t.literal("Up", "Right", "Look", "Z"), "Up")
local PlaySound = prelude.attribute("PlaySound", prelude.isBoolean, true)

local debounced: std.Set<BasePart> = {}

local function reset(launcher: BasePart)
	debounced[launcher] = nil
	prelude.Activatable:set(launcher, false)
end

local function launch(trove: std.Trove, parent: BasePart, power: number, maxAxesForce: Vector3, vector: Vector3)
	local velocityAttachment = trove:add(Instance.new("Attachment"))
	velocityAttachment.Name = "LauncherAttachment"

	local velocity = trove:add(Instance.new("LinearVelocity"))
	velocity.Name = "LauncherVelocity"
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	velocity.Attachment0 = velocityAttachment
	velocity.ForceLimitsEnabled = true
	velocity.MaxAxesForce = maxAxesForce
	velocity.VectorVelocity = vector * power
	velocity.Parent = velocityAttachment

	velocityAttachment.Parent = parent
end

local function tryLaunchPlauer(trove: std.Trove, instance: BasePart)
	if not prelude.Enabled(instance) or debounced[instance] then
		return
	end

	debounced[instance] = true
	prelude.Activatable:set(instance, false)

	local maxForce = MaxForce(instance)
	local launcherVector: Vector = Vector(instance)

	local faceVector: Vector3
	if launcherVector == "Up" then
		faceVector = instance.CFrame.UpVector
	elseif launcherVector == "Right" then
		faceVector = instance.CFrame.RightVector
	elseif launcherVector == "Look" then
		faceVector = instance.CFrame.LookVector
	elseif launcherVector == "Z" then
		faceVector = instance.CFrame.ZVector
	else
		std.never()
	end

	-- NOTE: do not do Vector3.yAxis * math.huge
	local maxAxesForce = Vector3.new(0, maxForce, 0)
	if faceVector.X ~= 0 then
		maxAxesForce = Vector3.new(maxForce, maxAxesForce.Y, maxAxesForce.Z)
	end
	if faceVector.Z ~= 0 then
		maxAxesForce = Vector3.new(maxAxesForce.X, maxAxesForce.Y, maxForce)
	end

	local root = prelude.getHumanoidRootPart()

	local velocityTrove = trove:extend()
	launch(velocityTrove, root, Power(instance), maxAxesForce, faceVector)

	if PlaySound(instance) then
		prelude.inferAndPlaySound(instance, prelude.AUDIO_ASSETS["core/towerSfx/button"], "LaunchSound")
	end

	if EmitLauncherParticle(instance) then
		local launchParticles = instance:FindFirstChild("LaunchParticle")
		if launchParticles and launchParticles:IsA("ParticleEmitter") then
			launchParticles:Emit(1)
		end
	end

	task.delay(Cooldown(instance), reset, instance)

	-- ???
	RunService.PostSimulation:Wait()
	RunService.PostSimulation:Wait()
	velocityTrove:clean()
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Launcher = kit:tag("Launcher", prelude.isBasePart)
	Launcher:onActivated(tryLaunchPlauer)
end

return self
