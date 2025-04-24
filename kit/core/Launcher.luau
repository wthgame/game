--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

type Vector = "Up" | "Right" | "Look" | "Z"

local EmitLauncherParticle = utils.attribute("EmitLauncherParticle", utils.t.boolean, true)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 1)
local Power = utils.attribute("Power", utils.t.numberPositive, 0)
local MaxForce = utils.attribute("MaxForce", utils.t.numberPositive, math.huge)
local Vector = utils.attribute("Vector", utils.t.literal("Up", "Right", "Look", "Z"), "Up")
local PlaySound = utils.attribute("PlaySound", utils.t.boolean, true)
local Sound = utils.attribute("Sound", utils.t.string, utils.SOUND_ASSETS.dash)

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

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Launcher = kit:tag("Launcher", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Launcher:onLoaded(function(trove, instance)
		local debounce = false

		local function resetDebounce()
			debounce = false
		end

		trove:connect(instance.Touched, function(toucher)
			if not utils.Active(instance) or debounce then
				return
			end

			local isCharacterTouched = utils.isToucherCharacter(instance, toucher)
			if not isCharacterTouched then
				return
			end

			debounce = true

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
			launch(velocityTrove, root, Power(instance), maxAxesForce, faceVector)

			if PlaySound(instance) then
				utils.playSound(Sound(instance), instance)
			end

			if EmitLauncherParticle(instance) then
				local launchParticles = instance:FindFirstChild("LaunchParticle")
				if launchParticles and launchParticles:IsA("ParticleEmitter") then
					launchParticles:Emit(1)
				end
			end

			task.delay(Cooldown(instance), resetDebounce)

			-- ???
			RunService.PostSimulation:Wait()
			RunService.PostSimulation:Wait()
			velocityTrove:clean()
		end)
	end)
end

return self
