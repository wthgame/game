--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local DEFAULT_RESPAWN_SOUND = "rbxassetid://12222140"

export type NoCheckpointBehavior = "ReturnToSpawn" | "None"
export type TransitionMode = "FadeScreen" | "PivotCharacter" | "Instant"

local EmitCheckpointParticle = utils.attribute("EmitCheckpointParticle", utils.t.boolean, false)
local TeleportOffset = utils.attribute(
	"TeleportOffset",
	utils.t.union(utils.t.number, utils.t.Vector3, utils.t.CFrame),
	Vector3.new(0, 3, 0)
)

local _NoCheckpointBehavior: utils.InstanceAttribute<NoCheckpointBehavior> = (
	utils.attribute("NoCheckpointBehavior", utils.t.literal("ReturnToSpawn", "None"), "ReturnToSpawn")
)
local TransitionMode: utils.InstanceAttribute<TransitionMode> = (
	utils.attribute("TransitionMode", utils.t.literal("FadeScreen", "PivotCharacter", "Instant"), "Instant")
)
local FadeScreenColor = utils.attribute("FadeScreenColor", utils.t.Color3, Color3.new(0, 0, 0))

local PlaySound = utils.attribute("PlaySound", utils.t.boolean, false)
local ActivatedColor = utils.attribute("ActivatedColor", utils.t.Color3, Color3.new(0, 1, 0))
local DefaultColor = utils.attribute("DefaultColor", utils.t.Color3, Color3.new(0, 0, 0))

local currentCheckpoint: BasePart? = nil
local updateCheckpoint = utils.newSignal()
local debounce = false

local function tryEmitCheckpointParticles(checkpoint: Instance)
	if EmitCheckpointParticle(checkpoint) then
		for _, descendant in checkpoint:GetDescendants() do
			if descendant.Name == "CheckpointParticle" and descendant:IsA("ParticleEmitter") then
				descendant:Emit(descendant.Rate)
			end
		end
	end
end

local function activateCheckpoint(trove: utils.Trove, checkpoint: BasePart, activationTrove: utils.Trove)
	if currentCheckpoint == checkpoint then
		return
	end
	currentCheckpoint = checkpoint
	updateCheckpoint:Fire()
	tryEmitCheckpointParticles(checkpoint)
	if PlaySound(checkpoint) then
		utils.inferAndPlaySound(checkpoint, utils.AUDIO_ASSETS["core/towerSfx/button"], "Sound")
	end
end

local function fadeScreenForReturner(outerTrove: utils.Trove, returner: BasePart, root: BasePart, destination: CFrame)
	local trove = outerTrove:extend()

	-- NOTE: anchor the root so it doesnt, say, activate a checkpoint resetter
	-- while animating
	root.Anchored = true
	root.AssemblyLinearVelocity = Vector3.zero

	local screen = trove:add(Instance.new("ScreenGui"))
	screen.Name = "CheckpointReturnerFadeScreen"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true

	local frame = trove:add(Instance.new("Frame"))
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = FadeScreenColor(returner)
	frame.BackgroundTransparency = 1

	frame.Parent = screen
	screen.Parent = Players.LocalPlayer.PlayerGui

	local config = utils.tweenConfigFromAttributes(returner, "Transition")
	utils.tween(frame, { BackgroundTransparency = 0 }, config)

	task.wait(config.time)

	root:PivotTo(destination)
	root.Anchored = false
	utils.tween(frame, { BackgroundTransparency = 1 }, config)

	task.delay(config.time, trove.clean, trove)
end

local function returnToCheckpoint(trove: utils.Trove, returner: BasePart)
	local root = utils.getMaybeHumanoidRootPart()
	if root and currentCheckpoint and currentCheckpoint:IsDescendantOf(Workspace) then
		if debounce then
			return
		end

		debounce = true

		local offset = TeleportOffset(currentCheckpoint)
		local finalTeleportOffset = CFrame.new(Vector3.yAxis * -0.75)
		if typeof(offset) == "number" then
			finalTeleportOffset = CFrame.new(Vector3.yAxis * -offset)
		elseif typeof(offset) == "Vector3" then
			finalTeleportOffset = CFrame.new(offset)
		elseif typeof(offset) == "CFrame" then
			finalTeleportOffset = offset
		end

		local destination = currentCheckpoint:GetPivot() * finalTeleportOffset

		if PlaySound(returner) then
			utils.inferAndPlaySound(returner, DEFAULT_RESPAWN_SOUND, "Sound")
		end

		local mode: TransitionMode = TransitionMode(returner)
		if mode == "Instant" then
			root:PivotTo(destination)
		elseif mode == "PivotCharacter" then
			root.Anchored = true
			root.AssemblyLinearVelocity = Vector3.zero
			local config = utils.tweenConfigFromAttributes(returner, "Transition")
			utils.tween(root, { CFrame = destination }, config)
			task.wait(config.time)
			root.Anchored = false
		elseif mode == "FadeScreen" then
			fadeScreenForReturner(trove, returner, root, destination)
		end

		debounce = false
	end
end

local function resetCheckpoint()
	currentCheckpoint = nil
	updateCheckpoint:Fire()
end

local function symbolColorOf(target: Instance, checkpoint: Instance)
	return if checkpoint == currentCheckpoint then ActivatedColor(target) else DefaultColor(target)
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Checkpoint = kit:tag("Checkpoint", utils.isBasePart)
	local CheckpointReturner = kit:tag("CheckpointReturner", utils.isBasePart)
	local CheckpointResetter = kit:tag("CheckpointResetter", utils.isBasePart)

	kit.trove:add(resetCheckpoint)

	Checkpoint:onActivated(activateCheckpoint)
	CheckpointReturner:onActivated(returnToCheckpoint)
	CheckpointResetter:onActivated(resetCheckpoint)

	Checkpoint:onLoaded(function(trove, checkpoint)
		trove:connect(updateCheckpoint :: any, function()
			local tweenConfig = utils.tweenConfigFromAttributes(checkpoint, "Transition")
			for _, descendant in checkpoint:GetDescendants() do
				if descendant.Name == "CheckpointSymbol" then
					if descendant:IsA("ImageLabel") then
						utils.tweenMaybeInstant(
							descendant,
							{ ImageColor3 = symbolColorOf(descendant, checkpoint) },
							tweenConfig
						)
					end
				end
			end
		end)
	end)
end

return self
