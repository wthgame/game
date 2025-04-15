--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local ALLOWED_CFRAME_COMPONENTS = {
	"UpVector",
	"RightVector",
	"LookVector",
	"ZVector",
}

local function launch(trove: utils.Trove, part: BasePart, currentMaxForce: Vector3, faceVector: Vector3, power: number)
	local velocityAttachment = Instance.new("Attachment")
	velocityAttachment.Parent = part

	local velocity = trove:add(Instance.new("LinearVelocity"))
	velocity.Name = "JumpPadVelocity"
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	velocity.Attachment0 = velocityAttachment
	velocity.ForceLimitsEnabled = true
	velocity.MaxAxesForce = currentMaxForce
	velocity.VectorVelocity = faceVector * power
	velocity.Parent = part
end

local function emitRingOfFire(part: BasePart)
	local ringOfFire = utils.createRingOfFire()
	ringOfFire.Enabled = false
	ringOfFire.Parent = part
	ringOfFire:Emit(1)
	task.wait(ringOfFire.Lifetime.Max)
	ringOfFire:Destroy()
end

local isAllowedCFrameComponent = utils.t.literalList(ALLOWED_CFRAME_COMPONENTS :: any)

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "JumpPad"

function mech:init(wth)
	local JumpPad: utils.Entity<BasePart> = wth:useTag("JumpPad", utils.t.instanceIsA("BasePart"))
	local Power = wth:useAttribute("Power", JumpPad, utils.t.numberPositive, 0)
	local MaxForce = wth:useAttribute("MaxForce", JumpPad, utils.t.numberPositive, math.huge)
	local Vector = wth:useAttribute("Vector", JumpPad, isAllowedCFrameComponent, "UpVector")
	local Cooldown = wth:useAttribute("Cooldown", JumpPad, utils.t.numberPositive, 0)
	local UseRingOfFire = wth:useAttribute("UseRingOfFire", JumpPad, utils.t.boolean, true)
	local PassCharacter = wth:useAttribute("PassCharacter", JumpPad, utils.t.boolean, true)

	local padTroves: { [BasePart]: utils.Trove } = {}

	local queryJumpPads =
		wth.world:query(JumpPad, Power, MaxForce, Vector, Cooldown, UseRingOfFire, PassCharacter):cached()

	local function checkJumpPads(_, trove: utils.Trove)
		local character = utils.getMaybeCharacter()
		local root = utils.getMaybeHumanoidRootPart()

		for entity, pad, power, maxForce, vec, cooldown, useRingOfFire, passCharacter in queryJumpPads:iter() do
			local touchConfig: utils.TouchConfig = {
				passLocalPlayerCharacter = passCharacter,
			}

			local partsTouched = utils.getPartTouched(pad, touchConfig)

			for part, trove in padTroves do
				if partsTouched[part] == nil then
					continue
				end
			end

			if next(partsTouched) == nil then
				continue
			end

			local faceVector: Vector3 = (pad.CFrame :: any)[vec]
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
				if padTroves[part] then
					continue
				end

				if character then
					if character:IsAncestorOf(part) then
						if alreadyElevatedCharacter then
							continue
						end

						alreadyElevatedCharacter = true

						if root then
							local padTrove = trove:extend()

							launch(padTrove, root, currentMaxForce, faceVector, power)
							if useRingOfFire then
								task.spawn(emitRingOfFire, pad)
							end

							trove:add(RunService.PostSimulation:Once(function()
								padTrove:destroy()
								padTrove[part] = nil
							end))

							padTrove[part] = padTrove
						end

						continue
					end
				end
			end
		end
	end

	wth:schedule(checkJumpPads)
end

return mech

--[[

    return function()
	local db = true
	local players = not script.Parent:FindFirstChild("IgnorePlayers")
	local boxes = not script.Parent:FindFirstChild("IgnoreBoxes")
	script.Parent.Touched:Connect(function(hit)
		if hit.Anchored == false and db == true and ((players and hit.Parent:FindFirstChild("Humanoid")) or (boxes and hit.Name == "Pushbox")) and not (script.Parent:FindFirstChild("Activated") and not script.Parent.Activated.Value) then
			db = false
			spawn(function()
				wait(0.05)
				db = true
			end)
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(0, math.huge, 0)
			bv.Velocity = Vector3.new(0, script.Parent.Power.Value, 0)
			bv.Parent = hit
			game:GetService("Debris"):AddItem(bv,0.15)
		end
	end)
    end
]]
