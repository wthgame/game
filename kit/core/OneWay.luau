--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local OneWayOffset = prelude.attribute("OneWayOffset", prelude.t.CFrame, CFrame.identity)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
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
			local look = CFrame.lookAt(
				(partPivot * (CFrame.new(Vector3.yAxis * (toUpdate.Size.Y * 0.5)) * OneWayOffset(toUpdate))).Position,
				(rootPivot * CFrame.new(0, -math.sign(upVector:Dot(Vector3.yAxis)), 0)).Position
			).LookVector
			local active = prelude.Active(toUpdate) and upVector:Dot(look) > 0
			if toUpdate.CanCollide ~= active then
				toUpdate.CanCollide = active
			end
		end
		debug.profileend()
	end)
end

return self
