--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage:WaitForChild("Lib"))

type FollowCharacterPartAttributes = {
	Enabled: boolean,
	Mode: "MoveToCharacter" | "FollowCharacterRotation" | "PivotToCharacter" | "LookAtCharacter",
	UseXAxis: boolean,
	UseYAxis: boolean,
	UseZAxis: boolean,
	Lerp: boolean,
	LerpSmoothness: number,
	Persistent: boolean,
}

local function applyAxisTransform(
	originalCFrame: CFrame,
	targetCFrame: CFrame,
	attributes: FollowCharacterPartAttributes
): CFrame
	local currentPosition = originalCFrame.Position
	local targetPosition = targetCFrame.Position

	local newX = if attributes.UseXAxis then targetPosition.X else currentPosition.X
	local newY = if attributes.UseYAxis then targetPosition.Y else currentPosition.Y
	local newZ = if attributes.UseZAxis then targetPosition.Z else currentPosition.Z

	local currentRotation = originalCFrame.Rotation
	local targetRotation = targetCFrame.Rotation

	local rx, ry, rz = currentRotation:ToEulerAnglesXYZ()
	local tx, ty, tz = targetRotation:ToEulerAnglesXYZ()

	if not attributes.UseXAxis then
		tx = rx
	end

	if not attributes.UseYAxis then
		ty = ry
	end

	if not attributes.UseZAxis then
		tz = rz
	end

	return CFrame.new(newX, newY, newZ) * CFrame.fromEulerAnglesXYZ(tx, ty, tz)
end

local self = {} :: lib.Mechanic
self.type = "Mechanic"
self.name = "FollowCharacterPart"

function self.attach(wth)
	local FollowCharacterPart: lib.Entity<Model | BasePart> = wth.trackCollectionServiceTag(
		"FollowCharacterPart",
		lib.t.union(lib.t.instanceIsA("Model"), lib.t.instanceIsA("BasePart"))
	)

	local FollowCharacterPartAttributes: lib.Entity<FollowCharacterPartAttributes> = wth.createMechanicAttributes(
		FollowCharacterPart,
		{
			Enabled = lib.t.boolean,
			Mode = lib.t.literalList({
				"MoveToCharacter",
				"FollowCharacterRotation",
				"PivotToCharacter",
				"LookAtCharacter",
			}),
			UseXAxis = lib.t.boolean,
			UseYAxis = lib.t.boolean,
			UseZAxis = lib.t.boolean,
			Lerp = lib.t.boolean,
			LerpSmoothness = lib.t.numberPositive,
			Persistent = lib.t.boolean,
		},
		{
			Enabled = true,
			Mode = "Move",
			UseXAxis = true,
			UseYAxis = true,
			UseZAxis = true,
			Lerp = true,
			LerpSmoothness = 40,
			Persistent = false,
		}
	)

	local queryFollowCharacterParts = wth.world:query(FollowCharacterPart):cached()

	local function updateFollowCharacterParts()
		local root = lib.getMaybeHumanoidRootPart()

		if not root then
			return
		end

		for entity, pv in queryFollowCharacterParts:iter() do
			local attributes = wth.world:get(entity, FollowCharacterPartAttributes)
			if not attributes then
				continue
			end

			if not attributes.Enabled then
				continue
			end

			local currentPivot = pv:GetPivot()

			if attributes.Mode == "MoveToCharacter" then
				pv:PivotTo(applyAxisTransform(currentPivot, CFrame.new(root.Position), attributes))
			elseif attributes.Mode == "FollowCharacterRotation" then
				pv:PivotTo(
					applyAxisTransform(
						currentPivot,
						CFrame.new(currentPivot.Position) * root.CFrame.Rotation,
						attributes
					)
				)
			elseif attributes.Mode == "PivotToCharacter" then
				pv:PivotTo(
					applyAxisTransform(
						CFrame.new(root.Position) * currentPivot.Rotation,
						CFrame.new(root.Position) * root.CFrame.Rotation,
						attributes
					)
				)
			elseif attributes.Mode == "LookAtCharacter" then
				pv:PivotTo(
					applyAxisTransform(currentPivot, CFrame.lookAt(currentPivot.Position, root.Position), attributes)
				)
			end
		end
	end

	wth.pushSystems(updateFollowCharacterParts)
end

return self
