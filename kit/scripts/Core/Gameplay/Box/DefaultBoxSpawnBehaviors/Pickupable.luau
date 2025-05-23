--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local BoxTypes = require("../BoxTypes")
local Dismounter = require("../../Dismounter")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

export type PickupPivot = "Player" | "Box"
export type Pickup = "Overhead" | "Front" | Vector3 | CFrame

local PROMPT_NAME = "PickupableBoxPrompt"

-- TODO: this can easily become a KitObject. for that to work we would probably
-- need to implement kit objects post init.
local Pickupable = {} :: BoxTypes.BoxSpawnBehavior
Pickupable.implements = { BoxSpawnBehavior = true }
Pickupable.name = "Pickupable"

local PickupPivot: std.Attribute<PickupPivot> = (
	prelude.attribute("PickupPivot", prelude.t.literal("Player", "Box"), "Player")
)
local Pickup: std.Attribute<Pickup> = prelude.attribute(
	"Pickup",
	prelude.t.union(prelude.t.literal("Overhead", "Front"), prelude.t.Vector3, prelude.t.CFrame),
	"Overhead"
)
local Stackable = prelude.attribute("Stackable", prelude.isBoolean, true)
-- TODO: generalized activation so we can also have ThrowableActivationBehavior?
local Throwable = prelude.attribute("Throwable", prelude.isBoolean, true)
local ThrowForce = (
	prelude.attribute("ThrowForce", prelude.t.union(prelude.isPositiveNumber, prelude.t.Vector3, prelude.t.CFrame), 0)
)

local logger = prelude.createLogger("Box.Pickupable")
local isCarrying = false

-- Top functions of all time
local function calcPickupCFrame(box: BasePart, root: BasePart, pivot: PickupPivot, pickup: Pickup): CFrame
	return if pivot == "Player"
		then if pickup == "Overhead"
			then root.CFrame * CFrame.new(0, box.Size.Y / 2 + 2.5, 0)
			elseif pickup == "Front" then root.CFrame * CFrame.new(0, box.Size.Y / 4, -box.Size.Z / 2 - 1.5)
			else root.CFrame * std.physics.intoCFrameOffset(pickup)
		elseif pivot == "Box" then if pickup == "Overhead"
			then box.CFrame * CFrame.new(0, 0.5 - box.Size.Y, 0)
			elseif pickup == "Front" then box.CFrame * CFrame.new(0, -box.Size.Y / 4, 1.5 - box.Size.Z / 2)
			else box.CFrame * std.physics.intoCFrameOffset(pickup)
		else std.never(pivot)
end

function Pickupable:spawn(trove, box)
	logger:debug("Implementing Pickupable for box", box:GetFullName())

	local function enableActivatable()
		prelude.Activatable:set(box, true)
	end

	prelude.onActivated(trove, box, function(trove, box)
		-- if isCarrying then
		-- 	return
		-- end

		local root = prelude.getMaybeHumanoidRootPart()
		if not root then
			return
		end

		-- isCarrying = true
		local wasActivatable = prelude.Activatable(box)
		prelude.Activatable:set(box, false)

		local pickupTrove = trove:extend()
		pickupTrove:attachToInstance(box)

		local pivot: PickupPivot = PickupPivot(box)
		local pickupCFrame = calcPickupCFrame(box, root, pivot, Pickup(box))
		if pivot == "Box" then
			root.CFrame = pickupCFrame
		elseif pivot == "Player" then
			box.CFrame = pickupCFrame
		else
			std.never()
		end

		std.physics.weld(pickupTrove, root, box)

		if wasActivatable then
			pickupTrove:add(enableActivatable)
		end

		pickupTrove:connect(Dismounter.onDismount :: any, function(targets)
			if targets.PickupableBox then
				pickupTrove:clean()
			end
		end)

		if Throwable(box) then
			pickupTrove:connect(UserInputService.JumpRequest, function()
				pickupTrove:clean()

				root = prelude.getMaybeHumanoidRootPart()
				if root then
					-- ts pmo
					-- local vel = (root.CFrame * std.physics.intoCFrameOffset(ThrowOffset(box))).LookVector
					-- 	* ThrowForce(box)
					-- logger:debug(vel)
					-- box.AssemblyLinearVelocity = vel

					local throwTrove = trove:extend()
					local throwAttachment = throwTrove:add(Instance.new("Attachment"))
					throwAttachment.Name = "ThrowAttachment"

					local throwVelocity = throwTrove:add(Instance.new("LinearVelocity"))
					throwVelocity.Parent = box
					throwVelocity.Attachment0 = throwAttachment
					throwVelocity.MaxForce = math.huge
					throwVelocity.VectorVelocity = root.CFrame.LookVector
						* std.physics.intoCFrameOffset(ThrowForce(box)).Position
					throwVelocity.Enabled = true

					throwAttachment.Parent = box

					RunService.PostSimulation:Wait()
					throwTrove:clean()

					local humanoid = prelude.getMaybeHumanoid() :: Humanoid
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
			end)
		end
	end)
end

return Pickupable
