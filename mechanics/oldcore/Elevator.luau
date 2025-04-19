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

local function elevate(trove: utils.Trove, part: BasePart, currentMaxForce: Vector3, faceVector: Vector3, speed: number)
	local velocityAttachment = Instance.new("Attachment")
	velocityAttachment.Parent = part

	local velocity = trove:add(Instance.new("LinearVelocity"))
	velocity.Name = "ElevatorVelocity"
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	velocity.Attachment0 = velocityAttachment
	velocity.ForceLimitsEnabled = true
	velocity.MaxAxesForce = currentMaxForce
	velocity.VectorVelocity = faceVector * speed
	velocity.Parent = part
end

local isAllowedCFrameComponent = utils.t.literalList(ALLOWED_CFRAME_COMPONENTS :: any)

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Elevator"

function mech:init(wth)
	local Elevator: utils.Entity<BasePart> = wth:useTag("Elevator", utils.t.instanceIsA("BasePart"))
	local Speed = wth:useAttribute("Speed", Elevator, utils.t.numberPositive, 0)
	local MaxForce = wth:useAttribute("MaxForce", Elevator, utils.t.numberPositive, math.huge)
	local Vector = wth:useAttribute("Vector", Elevator, isAllowedCFrameComponent, "UpVector")
	local PassCharacter = wth:useAttribute("PassCharacter", Elevator, utils.t.boolean, true)

	local elevatorTroves: { [BasePart]: utils.Trove } = {}

	local queryElevators = wth.world:query(Elevator, Speed, MaxForce, Vector, PassCharacter):cached()

	local function checkElevators(_, trove: utils.Trove)
		local character = utils.getMaybeCharacter()
		local root = utils.getMaybeHumanoidRootPart()

		for entity, elevator, speed, maxForce, vec, passCharacter in queryElevators:iter() do
			local touchConfig: utils.TouchConfig = {
				passLocalPlayerCharacter = passCharacter,
			}

			local partsTouched = utils.getPartTouched(elevator, touchConfig)

			for part, trove in elevatorTroves do
				if partsTouched[part] == nil then
					-- FIXME: why tf i need to cast this??
					(trove :: utils.Trove):destroy()
					elevatorTroves[part] = nil
				end
			end

			if next(partsTouched) == nil then
				continue
			end

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

			local alreadyElevatedCharacter = false

			for part in partsTouched do
				if elevatorTroves[part] then
					continue
				end

				if character then
					if character:IsAncestorOf(part) then
						if alreadyElevatedCharacter then
							continue
						end

						alreadyElevatedCharacter = true

						if root then
							local elevatorTrove = trove:extend()
							elevate(elevatorTrove, root, currentMaxForce, faceVector, speed)
							elevatorTroves[part] = elevatorTrove
						end

						continue
					end
				end
			end
		end
	end

	wth:schedule(checkElevators)
end

return mech
