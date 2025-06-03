--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local OneWayOffset = prelude.Attribute("OneWayOffset", prelude.t.CFrame, CFrame.identity)

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local OneWay = kit:tag("OneWay", prelude.isBasePart)

	kit:onPhysics(function()
		debug.profilebegin("OneWay")
		local root = prelude.getMaybeHumanoidRootPart()
		if not root then
			return
		end
		local rootPivot = root:GetPivot()
		for _, toUpdate in OneWay:instances() do
			local partPivot = toUpdate:GetPivot()
			local upVector = partPivot.UpVector
			-- etoh v6 dark magic
			local active = prelude.Enabled(toUpdate)
				and upVector:Dot(
						CFrame.lookAt(
							(partPivot * (CFrame.new(Vector3.yAxis * (toUpdate.Size.Y * 0.5)) * OneWayOffset(toUpdate))).Position,
							(rootPivot * CFrame.new(0, -math.sign(upVector:Dot(Vector3.yAxis)), 0)).Position
						).LookVector
					)
					> 0
			if toUpdate.CanCollide ~= active then
				toUpdate.CanCollide = active
			end
		end
		debug.profileend()
	end)
end

return self
