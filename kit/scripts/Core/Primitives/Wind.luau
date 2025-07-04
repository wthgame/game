--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type Vector = "Up" | "Right" | "Look" | "Z"

local Power = prelude.Attribute("Power", prelude.isPositiveNumber, 0)
local MaxForce = prelude.Attribute("MaxForce", prelude.isPositiveNumber, math.huge)
local Vector: std.Attribute<Vector> = (prelude.Attribute("Vector", prelude.t.literal("Up", "Right", "Look", "Z"), "Up"))

local function wind(trove: std.Trove, parent: BasePart, power: number, maxAxesForce: Vector3, vector: Vector3)
	local velocityAttachment = trove:add(Instance.new("Attachment"))
	velocityAttachment.Name = "WindAttachment"

	local velocity = trove:add(Instance.new("LinearVelocity"))
	velocity.Name = "WindVelocity"
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	velocity.Attachment0 = velocityAttachment
	velocity.ForceLimitsEnabled = true
	velocity.MaxAxesForce = maxAxesForce
	velocity.VectorVelocity = vector * power
	velocity.Parent = velocityAttachment

	velocityAttachment.Parent = parent
end

local function windUpTrove(
	outerTrove: std.Trove,
	part: BasePart,
	power: number,
	maxAxesForce: Vector3,
	faceVector: Vector3
): std.Trove
	local trove = outerTrove:extend()
	outerTrove:attachToInstance(part)
	wind(trove, part, power, maxAxesForce, faceVector)
	return trove
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Wind = kit:tag("Wind", prelude.isBasePart)

	Wind:onLoaded(function(trove, instance)
		local windTroves: std.Map<BasePart, std.Trove> = {}
		trove:connect(instance.Touched, function(toucher)
			if not prelude.Enabled(instance) then
				for part, trove in windTroves do
					(trove :: any):clean()
				end
				table.clear(windTroves)
				return
			end

			local partToWind: BasePart? = nil

			local isToucherCharacter = std.touch.isToucherCharacter(instance, toucher)

			if isToucherCharacter then
				-- For consistency, only wind up the humanoid root part.
				local root = prelude.getHumanoidRootPart()
				if windTroves[root] then
					return
				end
				partToWind = root
			end

			if not partToWind then
				return
			end

			local maxForce: number = MaxForce(instance)
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

			-- stylua: ignore
			local windTrove = windUpTrove(
			    trove,
				partToWind,
				Power(instance),
				maxAxesForce,
				faceVector
			)

			windTroves[partToWind] = windTrove
		end)

		trove:connect(instance.TouchEnded, function(toucher)
			local isToucherCharacter = std.touch.isToucherCharacter(instance, toucher)

			if isToucherCharacter then
				-- For consistency, only the humanoid root part should be winded
				-- up.
				local root = prelude.getHumanoidRootPart()
				local rootTrove = windTroves[root]
				if rootTrove then
					rootTrove:clean()
					windTroves[root] = nil
					return
				end
			end

			local trove = windTroves[toucher]
			if trove then
				trove:clean()
				windTroves[toucher] = nil
			end
		end)
	end)
end

return self
