--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Dismounter = require("../Gameplay/Dismounter")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @type CarryPivot "Player" | "Self"
--- @within Carryable
---
--- The object to pivot when carried. "Player" means the Carryable's position is
--- pivoted to the player, "Self" means the player's position is pivoted to the Carryable.
export type CarryPivot = "Player" | "Self"

--- @type Carry "Overhead" | "Front" | Vector3 | CFrame
--- @within Carryable
---
--- The position of the Carryable when carried:
---
--- * "Overhead" means the Carryable carried overhead
--- * "Front" means the Carryable is carried in front of the player,
--- * Vector3 values means the Carryable is carried at a specific position relative to the player
--- * CFrame values means the Carryable is carried at a specific position and orientation relative to the player.
export type Carry = "Overhead" | "Front" | Vector3 | CFrame

--- @class Carryable
--- @tag KitObject
--- @tag Activatable
---
--- When activated, the player will carry the Carryable, which can be thrown.
local Carryable = {}
type Self = typeof(Carryable)
Carryable.implements = { KitScript = true }
Carryable.name = "Carryable"

--- @prop CarryPivot std.Attribute<CarryPivot>
--- @tag Attribute
--- @within Carryable
---
--- The object to pivot when carried. See the `CarryPivot` type.
Carryable.CarryPivot = (
	prelude.Attribute("CarryPivot", prelude.t.literal("Player", "Self"), "Player")
) :: std.Attribute<CarryPivot>

--- @prop Carry std.Attribute<Carry>
--- @tag Attribute
--- @within Carryable
---
--- The position of the Carryable when carried. See the `Carry` type.
Carryable.Carry = prelude.Attribute(
	"Carry",
	prelude.t.union(prelude.t.literal("Overhead", "Front"), prelude.t.Vector3, prelude.t.CFrame),
	"Overhead"
) :: std.Attribute<Carry>

-- TODO: implement stacking
-- local Stackable = prelude.Attribute("Stackable", prelude.isBoolean, true)

--- @prop Throwable std.Attribute<boolean>
--- @tag Attribute
--- @within Carryable
---
--- If true, the Carryable can be thrown by the player.
-- TODO: generalized activation so we can also have ThrowableActivationBehavior?
local Throwable = prelude.Attribute("Throwable", prelude.isBoolean, true)

--- @prop ThrowForce std.Attribute<number | Vector3 | CFrame>
--- @tag Attribute
--- @within Carryable
---
--- The force or velocity applied when the Carryable is thrown. Can be a number
--- (magnitude), a Vector3 (direction and magnitude), or a CFrame (direction and
--- orientation).
local ThrowForce = (
	prelude.Attribute("ThrowForce", prelude.t.union(prelude.isPositiveNumber, prelude.t.Vector3, prelude.t.CFrame), 0)
)

-- local logger = prelude.createLogger("Carryable")
-- local isCarrying = false

-- Top functions of all time
local function calcCarryCFrame(carryable: BasePart, root: BasePart, pivot: CarryPivot, pickup: Carry): CFrame
	return if pivot == "Player"
		then if pickup == "Overhead"
			then root.CFrame * CFrame.new(0, carryable.Size.Y / 2 + 2.5, 0)
			elseif pickup == "Front" then root.CFrame * CFrame.new(
				0,
				carryable.Size.Y / 4,
				-carryable.Size.Z / 2 - 1.5
			)
			else root.CFrame * std.physics.intoCFrameOffset(pickup)
		elseif pivot == "Self" then if pickup == "Overhead"
			then carryable.CFrame * CFrame.new(0, 0.5 - carryable.Size.Y, 0)
			elseif pickup == "Front" then carryable.CFrame * CFrame.new(
				0,
				-carryable.Size.Y / 4,
				1.5 - carryable.Size.Z / 2
			)
			else carryable.CFrame * std.physics.intoCFrameOffset(pickup)
		else std.never(pivot)
end

function Carryable.run(self: Self, kit: std.Kit)
	kit:tag("Carryable", prelude.isBasePart):onActivated(function(trove, carryable)
		local function enableActivatable()
			prelude.Activatable:set(carryable, true)
		end

		prelude.onActivated(trove, carryable, function(trove, carryable)
			-- if isCarrying then
			-- 	return
			-- end

			local root = prelude.getMaybeHumanoidRootPart()
			if not root then
				return
			end

			-- isCarrying = true
			local wasActivatable = prelude.Activatable(carryable)
			prelude.Activatable:set(carryable, false)

			local pickupTrove = trove:extend()
			pickupTrove:attachToInstance(carryable)

			local pivot: CarryPivot = self.CarryPivot(carryable)
			local pickupCFrame = calcCarryCFrame(carryable, root, pivot, self.Carry(carryable))
			if pivot == "Self" then
				root.CFrame = pickupCFrame
			elseif pivot == "Player" then
				carryable.CFrame = pickupCFrame
			else
				std.never()
			end

			std.physics.weld(pickupTrove, root, carryable)

			if wasActivatable then
				pickupTrove:add(enableActivatable)
			end

			pickupTrove:connect(Dismounter.onDismount :: any, function(targets)
				if targets.CarryableBox then
					pickupTrove:clean()
				end
			end)

			if Throwable(carryable) then
				pickupTrove:connect(UserInputService.JumpRequest, function()
					pickupTrove:clean()

					root = prelude.getMaybeHumanoidRootPart()
					if root then
						-- ts pmo
						-- local vel = (root.CFrame * std.physics.intoCFrameOffset(ThrowOffset(carryable))).LookVector
						-- 	* ThrowForce(carryable)
						-- logger:debug(vel)
						-- carryable.AssemblyLinearVelocity = vel

						local throwTrove = trove:extend()
						local throwAttachment = throwTrove:add(Instance.new("Attachment"))
						throwAttachment.Name = "ThrowAttachment"

						local throwVelocity = throwTrove:add(Instance.new("LinearVelocity"))
						throwVelocity.Parent = carryable
						throwVelocity.Attachment0 = throwAttachment
						throwVelocity.MaxForce = math.huge
						throwVelocity.VectorVelocity = root.CFrame.LookVector
							* std.physics.intoCFrameOffset(ThrowForce(carryable)).Position
						throwVelocity.Enabled = true

						throwAttachment.Parent = carryable

						RunService.PostSimulation:Wait()
						throwTrove:clean()

						local humanoid = prelude.getMaybeHumanoid() :: Humanoid
						humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
					end
				end)
			end
		end)
	end)
end

return Carryable
