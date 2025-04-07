--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

-- PickupablePushboxSpawner is based on the PickupablePushbox client object from
-- the Total Fire Towers v2 game.
--
-- TODO: this code stinks and smells please rewrite it

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type PickupType = "Overhead" | "Front" | "Custom"
type PickupBehavior = "TeleportToBox" | "TeleportToPlayer"

type PickupablePushboxSpawnerAttributes = {
	DoNotSpawnFirst: boolean,
	CooldownSeconds: number,
	PickupType: PickupType,
	PickupBehavior: PickupBehavior,
	Throwable: boolean,
	ThrowForce: number,
	PushboxHoldOffset: Vector3,
	PassLocalPlayerCharacter: boolean,
}

type PickupablePushboxSpawnerInstance = Instance & {
	Pushbox: Instance,
	Button: BasePart,
}

local ANIMATIONS = {
	Overhead = "rbxassetid://16950940551",
	Frontfacing = "rbxassetid://16950950394",
}

local self = {} :: utils.Mechanic<PickupablePushboxSpawnerAttributes, PickupablePushboxSpawnerInstance>
self.type = "Mechanic"
self.name = "PickupablePushboxSpawner"

self.attributes = {
	DoNotSpawnFirst = utils.t.boolean,
	CooldownSeconds = utils.t.numberPositive,
	PickupType = utils.t.literalList({ "Overhead", "Front", "Custom" }),
	PickupBehavior = utils.t.literalList({ "TeleportToBox", "TeleportToPlayer" }),
	Throwable = utils.t.boolean,
	ThrowForce = utils.t.numberPositive,
	PushboxHoldOffset = utils.t.Vector3,
	PassLocalPlayerCharacter = utils.t.boolean,
}

self.defaultAttributes = {
	DoNotSpawnFirst = true,
	CooldownSeconds = 0,
	PickupType = "Overhead",
	PickupBehavior = "TeleportToPlayer",
	Throwable = true,
	ThrowForce = 25,
	PushboxHoldOffset = Vector3.new(0, 0, 0),
	PassLocalPlayerCharacter = true,
}

self.instanceCheck = utils.t.children({
	Pushbox = utils.t.Instance,
	Button = utils.t.instanceIsA("BasePart"),
})

local function calculatePushboxCFrame(
	pushbox: BasePart,
	humanoidRootPart: BasePart,
	pickupBehavior: PickupBehavior,
	pickupType: PickupType,
	customOffset: Vector3
): CFrame
	if pickupBehavior == "TeleportToPlayer" then
		if string.lower(pickupType) == "overhead" then
			return humanoidRootPart.CFrame * CFrame.new(0, pushbox.Size.Y / 2 + 2.5, 0)
		elseif string.lower(pickupType) == "frontfacing" then
			return humanoidRootPart.CFrame * CFrame.new(0, pushbox.Size.Y / 4, -(pushbox.Size.Z / 2) - 1.5)
		end

		return humanoidRootPart.CFrame * CFrame.new(customOffset)
	end

	if string.lower(pickupType) == "overhead" then
		return pushbox.CFrame * CFrame.new(0, -pushbox.Size.Y + 0.5, 0)
	elseif string.lower(pickupType) == "frontfacing" then
		return pushbox.CFrame * CFrame.new(0, -(pushbox.Size.Y / 4), pushbox.Size.Z / 2 + 1.5)
	end

	return pushbox.CFrame * CFrame.new(customOffset)
end

local function changePushboxBasePartProperties(pushbox: Instance, property: string, value: any)
	if pushbox:IsA("BasePart") then
		(pushbox :: any)[property] = value
	else
		for _, descendant in pushbox:GetDescendants() do
			if descendant:IsA("BasePart") then
				(descendant :: any)[property] = value
			end
		end
	end
end

-- TODO: once proper animation is implemented, swap this out with actual
-- animation utils
function self:mechanize(ctx)
	local currentPushbox: Instance = nil
	local promptAttachment: Attachment = nil
	local weld: WeldConstraint = nil
	local animationTrack: AnimationTrack = nil

	local isDisengaged = false
	local isCarrying = false
	local isThrown = false

	local animation = ctx:pushTasks(Instance.new("Animation"), script)
	local animator: Animator = utils.getHumanoid():WaitForChild("Animator") :: Animator
	local button, pushbox = ctx.instance.Button, ctx.instance.Pushbox

	local function spawnPushbox()
		if currentPushbox then
			currentPushbox:Destroy()
		end

		if promptAttachment then
			promptAttachment:Destroy()
		end

		if weld then
			weld:Destroy()
		end

		if animation then
			animation:Destroy()
		end

		if animationTrack then
			animationTrack:Stop()
			animationTrack:Destroy()
		end

		local newPushbox = pushbox:Clone()
		newPushbox.Parent = ctx.instance
		currentPushbox = newPushbox

		-- changePushboxBasePartProperties(newPushbox, "Anchored", ctx:getAttribute("StartsAnchored"))
		changePushboxBasePartProperties(newPushbox, "AssemblyLinearVelocity", Vector3.zero)

		-- TODO: utils.createPrompt() utility
		promptAttachment = newPushbox:FindFirstChild("PromptAttachment") :: Attachment
		if not promptAttachment or promptAttachment:IsA("Attachment") == false then
			local newPromptAttachment = ctx:pushTasks(Instance.new("Attachment"))
			newPromptAttachment.Name = "PromptAttachment"
			newPromptAttachment.Parent = newPushbox
			promptAttachment = newPromptAttachment
		end

		local proximityPrompt: ProximityPrompt = promptAttachment:FindFirstChild("ProximityPrompt") :: ProximityPrompt
		if not proximityPrompt or proximityPrompt:IsA("ProximityPrompt") == false then
			local newProximityPrompt = ctx:pushTasks(Instance.new("ProximityPrompt"))
			newProximityPrompt.ActionText = "Pickup"
			newProximityPrompt.ObjectText = ""
			newProximityPrompt.HoldDuration = 0
			newProximityPrompt.Parent = newPushbox
			proximityPrompt = newProximityPrompt
		end

		animation.AnimationId = ANIMATIONS[ctx:getAttribute("PickupType")] or "rbxassetid://16951389063"
		animationTrack = animator:LoadAnimation(animation)

		isDisengaged = false
		local Destroying: RBXScriptConnection = nil
		Destroying = pushbox.Destroying:Connect(function()
			isDisengaged = true
			Destroying:Disconnect()
		end)

		local removed: RBXScriptConnection = nil
		removed = utils.getCharacter().Destroying:Connect(function()
			isDisengaged = true
			removed:Disconnect()
		end)

		isCarrying = false
		proximityPrompt.Enabled = true
		ctx:pushTasks(proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
			if playerWhoTriggered ~= Players.LocalPlayer then
				return
			end

			if not isCarrying then
				isCarrying = true
				-- SoundService:PlayLocalSound(Configuration.Throwable_Pickup)
			end

			proximityPrompt.Enabled = false
			isDisengaged = false
			animationTrack:Play(0, 1, 1)
			utils.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

			local pickupBehavior: PickupBehavior = ctx:getAttribute("PickupBehavior")
			local pickupType: PickupType = ctx:getAttribute("PickupType")
			local humanoidRootPart = utils.getHumanoidRootPart()
			local character = utils.getCharacter()

			if pickupBehavior == "TeleportToBox" then
				-- Holy what drugs was i onto while writing this
				local oldValues = {}
				for _, value in character:GetDescendants() do
					if value:IsA("BasePart") then
						oldValues[value.Name] = value.CanCollide
						value.CanCollide = false
					end
				end

				-- FIXME: account for model pushboxes too
				humanoidRootPart.CFrame = calculatePushboxCFrame(
					newPushbox :: BasePart,
					humanoidRootPart,
					pickupBehavior,
					pickupType,
					ctx:getAttribute("PushboxHoldOffset")
				)

				for _, descendant in character:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.CanCollide = oldValues[descendant.Name]
					end
				end
			else
				-- FIXME: account for model pushboxes too
				(newPushbox :: BasePart).CFrame = calculatePushboxCFrame(
					newPushbox :: BasePart,
					humanoidRootPart,
					pickupBehavior,
					pickupType,
					ctx:getAttribute("PushboxHoldOffset")
				)
			end

			newPushbox.Parent = character
			weld = Instance.new("WeldConstraint")
			weld.Parent = newPushbox
			weld.Part0 = humanoidRootPart
			weld.Part1 = newPushbox :: BasePart

			changePushboxBasePartProperties(newPushbox, "Anchored", false)
			changePushboxBasePartProperties(newPushbox, "AssemblyLinearVelocity", Vector3.zero)

			isThrown = false
			local jumpRequest: RBXScriptConnection = nil

			if ctx:getAttribute("Throwable") then
				jumpRequest = UserInputService.JumpRequest:Connect(function()
					if isThrown ~= true then
						-- SoundService:PlayLocalSound(Throwable_Throw)
						isThrown = true
					end
					isDisengaged = true
					weld:Destroy()

					local linearVelocity = Instance.new("LinearVelocity")
					linearVelocity.Parent = newPushbox
					linearVelocity.Attachment0 = promptAttachment
					linearVelocity.MaxForce = math.huge
					linearVelocity.VectorVelocity = (
						utils.getHumanoidRootPart().CFrame.LookVector + ctx:getAttribute("PushboxHoldOffset")
					) * ctx:getAttribute("ThrowForce")
					linearVelocity.Enabled = true

					task.wait(0.1)

					linearVelocity:Destroy()
					jumpRequest:Disconnect()
				end)
			end

			repeat
				task.wait()
			until isDisengaged == true
			if newPushbox.Parent ~= nil then
				newPushbox.Parent = ctx.instance
			end

			animationTrack:Stop()
			utils.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

			if weld then
				weld:Destroy()
			end

			task.wait(ctx:getAttribute("CooldownSeconds"))

			proximityPrompt.Enabled = true
			isDisengaged = false
			isCarrying = false
		end))
	end

	local debounce = false
	ctx:pushTasks(button.Touched:Connect(function(toucher)
		if debounce then
			return
		end

		local touchConfig = {
			passLocalPlayerCharacters = ctx:getAttribute("PassLocalPlayerCharacter"),
		}

		if not utils.checkTouched(toucher, touchConfig) then
			return
		end

		spawnPushbox()

		debounce = true

		task.wait(ctx:getAttribute("SpawnCooldownSeconds"))

		debounce = false
	end))

	pushbox.Parent = nil

	if not ctx:getAttribute("DoNotSpawnFirst") then
		spawnPushbox()
	end
end

return self
