--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Vector = "Up" | "Right" | "Look" | "Z"
type LauncherAttributes = {
	Enabled: boolean,
	EmitLauncherParticle: boolean,
	Cooldown: number,
	Power: number,
	MaxForce: number,
	Vector: Vector,
	Sound: string,
	SupportsLocalCharacter: boolean,
}

local function launch(trove: utils.Trove, parent: BasePart, power: number, maxAxesForce: Vector3, vector: Vector3)
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

local function init(wth: utils.WTH)
	local Launcher = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Launcher",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Enabled = true,
			EmitLauncherParticle = true,
			Cooldown = 0,
			Power = 0,
			MaxForce = math.huge,
			Vector = "Up",
			PlaySound = true,
			Sound = utils.SOUND_ASSETS.dash,
			SupportsLocalCharacter = true,
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			EmitLauncherParticle = utils.t.boolean,
			Cooldown = utils.t.numberPositive,
			Power = utils.t.numberPositive,
			MaxForce = utils.t.numberPositive,
			Vector = utils.t.literal("Up", "Right", "Look", "Z"),
			PlaySound = utils.t.boolean,
			Sound = utils.t.string,
			SupportsLocalCharacter = utils.t.boolean,
		},
	} :: utils.Mechanic<BasePart, LauncherAttributes>

	function Launcher:loaded(trove, instance, kit)
		local debounce = false

		local function resetDebounce()
			debounce = false
		end

		trove:connect(instance.Touched, function(toucher)
			if self:attribute(instance, "Enabled") and not debounce and utils.isFromMaybeLocalCharacter(toucher) then
				debounce = true

				local maxForce: number = self:attribute(instance, "MaxForce")
				local launcherVector: Vector = self:attribute(instance, "Vector")

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
					error("Invalid Vector (unreachable?)")
				end

				-- NOTE: do not do Vector3.yAxis * math.huge
				local maxAxesForce = Vector3.new(0, maxForce, 0)
				if faceVector.X ~= 0 then
					maxAxesForce = Vector3.new(maxForce, maxAxesForce.Y, maxAxesForce.Z)
				end
				if faceVector.Z ~= 0 then
					maxAxesForce = Vector3.new(maxAxesForce.X, maxAxesForce.Y, maxForce)
				end

				local root = utils.getLocalHumanoidRootPart()

				local velocityTrove = trove:extend()
				launch(velocityTrove, root, self:attribute(instance, "Power"), maxAxesForce, faceVector)

				if self:attribute(instance, "PlaySound") then
					utils.playSound(self:attribute(instance, "Sound"), instance)
				end

				if self:attribute(instance, "EmitLauncherParticle") then
					print("LAUNCH PARTICLES")
					local launchParticles = instance:FindFirstChild("LaunchParticle")
					if launchParticles and launchParticles:IsA("ParticleEmitter") then
						print("GOT LAUNCH PARTICLES", launchParticles)
						launchParticles:Emit(1)
					end
				end

				task.delay(self:attribute(instance, "Cooldown"), resetDebounce)

				-- ???
				RunService.PostSimulation:Wait()
				RunService.PostSimulation:Wait()
				velocityTrove:clean()
			end
		end)
	end

	wth.registerMechanic(Launcher)
end

return init
