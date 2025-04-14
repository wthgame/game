--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local ALLOWED_CFRAME_COMPONENTS = {
	"UpVector",
	"RightVector",
	"LookVector",
	"ZVector",
}

local isAllowedCFrameComponent = utils.t.literalList(ALLOWED_CFRAME_COMPONENTS :: any)

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Elevator"

function mech:init(wth)
	local Elevator: utils.Entity<BasePart> = wth:useTag("Elevator", utils.t.instanceIsA("BasePart"))
	local Speed = wth:useAttribute("Elevator", Elevator, utils.t.numberPositive, 0)
	local MaxForce = wth:useAttribute("MaxForce", Elevator, utils.t.numberPositive, math.huge)
	local Vector = wth:useAttribute("Vector", Elevator, isAllowedCFrameComponent, "UpVector")
	local PassCharacter = wth:useAttribute("PassCharacter", Elevator, utils.t.boolean, true)
	local IsElevating: utils.Entity = wth.world:component()

	local queryElevators =
		wth.world:query(Elevator, Speed, MaxForce, Vector, PassCharacter):without(IsElevating):cached()

	local function checkElevators(_, trove: utils.Trove)
		for entity, elevator, speed, maxForce, vec, passCharacter in queryElevators:iter() do
			local touchConfig: utils.TouchConfig = {
				passLocalPlayerCharacters = passCharacter,
			}

			if not utils.isPartTouched(elevator, touchConfig) then
				continue
			end

			wth.world:set(entity, IsElevating)

			local faceVector: Vector3 = (elevator.CFrame :: any)[vec]
			if not faceVector then
				continue
			end

			-- NOTE: do not do Vector3.yAxis * math.huge
			local currentMaxForce = Vector3.new(0, maxForce, 0)
			if faceVector.X ~= 0 then
				currentMaxForce = Vector3.new(maxForce, currentMaxForce.Y, currentMaxForce.Z)
			end
			if faceVector.Z ~= 0 then
				currentMaxForce = Vector3.new(currentMaxForce.X, currentMaxForce.Y, maxForce)
			end

			local velocityAttachment = Instance.new("Attachment")
			velocityAttachment.Parent = elevator

			local velocity = Instance.new("LinearVelocity")
			velocity.Name = "ElevatorVelocity"
			velocity.RelativeTo = Enum.ActuatorRelativeTo.World
			velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
			velocity.Attachment0 = velocityAttachment
			velocity.ForceLimitsEnabled = true
			velocity.MaxAxesForce = currentMaxForce
			velocity.VectorVelocity = faceVector * speed
			velocity.Parent = elevator

			-- -- new touchended implementation --
			-- touchingParts[part] = true
			-- while touchingParts[part] do
			-- 	if not elevator.CanTouch then
			-- 		break
			-- 	end
			-- 	if utility.checkConfig(elevator, "Activated") == false then
			-- 		break
			-- 	end
			-- 	task.wait()
			-- 	local zoneParts: { BasePart } = workspace:GetPartsInPart(elevator, params)
			-- 	if #zoneParts <= 0 then
			-- 		break
			-- 	end
			-- end

			-- touchingParts[part] = nil
			-- velocity:Destroy()
			-- velocityAttachment:Destroy()
		end
	end

	wth:schedule(checkElevators)
end

return mech
