--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local wth = require(ReplicatedStorage:WaitForChild("Lib"))

type Self = wth.Mechanic<{
	FollowCharacterPart: wth.Entity<Model | BasePart>,
	Enabled: (instance: Instance) -> boolean,
	Mode: (instance: Instance) -> "MoveToCharacter" | "FollowCharacterRotation" | "PivotToCharacter" | "LookAtCharacter",
	UseXAxis: (instance: Instance) -> boolean,
	UseYAxis: (instance: Instance) -> boolean,
	UseZAxis: (instance: Instance) -> boolean,
	Lerp: (instance: Instance) -> boolean,
	LerpSmoothness: (instance: Instance) -> number,
	Persistent: (instance: Instance) -> boolean,

	applyAxisTransform: (Self, originalCFrame: CFrame, targetCFrame: CFrame, pv: PVInstance) -> CFrame,
}>

local mech = {} :: Self
mech.type = "Mechanic"
mech.name = "FollowCharacterPart"

mech.FollowCharacterPart = wth.trackCollectionServiceTag(
	"FollowCharacterPart",
	wth.t.union(wth.t.instanceIsA("Model"), wth.t.instanceIsA("BasePart"))
)
mech.Enabled = wth.createAttributeReconciler("Enabled", wth.t.boolean, true)
mech.Mode = wth.createAttributeReconciler(
	"Enabled",
	wth.t.literal("MoveToCharacter", "FollowCharacterRotation", "PivotToCharacter", "LookAtCharacter") :: any,
	"Move"
)
mech.UseXAxis = wth.createAttributeReconciler("UseXAxis", wth.t.boolean, true)
mech.UseYAxis = wth.createAttributeReconciler("UseYAxis", wth.t.boolean, true)
mech.UseZAxis = wth.createAttributeReconciler("UseZAxis", wth.t.boolean, true)
mech.Lerp = wth.createAttributeReconciler("Lerp", wth.t.boolean, true)
mech.LerpSmoothness = wth.createAttributeReconciler("LerpSmoothness", wth.t.numberPositive, 40)
mech.Persistent = wth.createAttributeReconciler("Persistent", wth.t.boolean, true)

function mech:applyAxisTransform(originalCFrame: CFrame, targetCFrame: CFrame, pv: PVInstance): CFrame
	local currentPosition = originalCFrame.Position
	local targetPosition = targetCFrame.Position

	local useX, useY, useZ = self.UseXAxis(pv), self.UseYAxis(pv), self.UseZAxis(pv)

	local newX = if useX then targetPosition.X else currentPosition.X
	local newY = if useY then targetPosition.Y else currentPosition.Y
	local newZ = if useZ then targetPosition.Z else currentPosition.Z

	local currentRotation = originalCFrame.Rotation
	local targetRotation = targetCFrame.Rotation

	local rx, ry, rz = currentRotation:ToEulerAnglesXYZ()
	local tx, ty, tz = targetRotation:ToEulerAnglesXYZ()

	if not useX then
		tx = rx
	end

	if not useY then
		ty = ry
	end

	if not useZ then
		tz = rz
	end

	return CFrame.new(newX, newY, newZ) * CFrame.fromEulerAnglesXYZ(tx, ty, tz)
end

function mech:init(schedule)
	local queryFollowCharacterParts = wth.world:query(self.FollowCharacterPart):cached()

	local function updateFollowCharacterParts()
		local root = wth.getMaybeHumanoidRootPart()

		if not root then
			return
		end

		for entity, pv in queryFollowCharacterParts:iter() do
			print("GOT PV", pv)
			-- if not self.Enabled(pv) then
			-- 	continue
			-- end

			local mode = self.Mode(pv)
			local currentPivot = pv:GetPivot()

			if mode == "MoveToCharacter" then
				pv:PivotTo(self:applyAxisTransform(currentPivot, CFrame.new(root.Position), pv))
			elseif mode == "FollowCharacterRotation" then
				pv:PivotTo(
					self:applyAxisTransform(currentPivot, CFrame.new(currentPivot.Position) * root.CFrame.Rotation, pv)
				)
			elseif mode == "PivotToCharacter" then
				pv:PivotTo(
					self:applyAxisTransform(
						CFrame.new(root.Position) * currentPivot.Rotation,
						CFrame.new(root.Position) * root.CFrame.Rotation,
						pv
					)
				)
			elseif mode == "LookAtCharacter" then
				pv:PivotTo(
					self:applyAxisTransform(currentPivot, CFrame.lookAt(currentPivot.Position, root.Position), pv)
				)
			end
		end
	end

	schedule(updateFollowCharacterParts)
end

return mech
