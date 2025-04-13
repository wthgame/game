--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type Mode = "MoveToCharacter" | "FollowCharacterRotation" | "PivotToCharacter" | "LookAtCharacter"

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "FollowCharacterPart"

local function applyAxisTransform(
	originalCFrame: CFrame,
	targetCFrame: CFrame,
	pv: PVInstance,
	useX: boolean,
	useY: boolean,
	useZ: boolean
): CFrame
	local currentPosition = originalCFrame.Position
	local targetPosition = targetCFrame.Position

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

function mech:init(wth)
	local FollowCharacterPart: utils.Entity<BasePart> =
		wth:useTag("FollowCharacterPart", utils.t.union(utils.t.instanceIsA("Model"), utils.t.instanceIsA("BasePart")))

	local Enabled = wth:useAttribute("Enabled", FollowCharacterPart, utils.t.boolean, true)
	local Mode: utils.Entity<Mode> = wth:useAttribute(
		"Mode",
		FollowCharacterPart,
		utils.t.literal("MoveToCharacter", "FollowCharacterRotation", "PivotToCharacter", "LookAtCharacter") :: any,
		"MoveToCharacter"
	)
	local UseXAxis = wth:useAttribute("UseXAxis", FollowCharacterPart, utils.t.boolean, true)
	local UseYAxis = wth:useAttribute("UseYAxis", FollowCharacterPart, utils.t.boolean, true)
	local UseZAxis = wth:useAttribute("UseZAxis", FollowCharacterPart, utils.t.boolean, true)
	local Lerp = wth:useAttribute("Lerp", FollowCharacterPart, utils.t.boolean, true)
	-- local LerpSmoothness = wth:useAttribute("LerpSmoothness", FollowCharacterPart, utils.t.numberPositive, 40)

	local queryFollowCharacterParts =
		wth.world:query(FollowCharacterPart, Enabled, Mode, UseXAxis, UseYAxis, UseZAxis, Lerp):cached()

	local function updateFollowCharacterParts()
		local root = utils.getMaybeHumanoidRootPart()

		if not root then
			return
		end

		for entity, pv, enabled, mode, useX, useY, useZ, lerp in queryFollowCharacterParts:iter() do
			if not enabled then
				continue
			end

			local currentPivot = pv:GetPivot()

			if mode == "MoveToCharacter" then
				pv:PivotTo(applyAxisTransform(currentPivot, CFrame.new(root.Position), pv, useX, useY, useZ))
			elseif mode == "FollowCharacterRotation" then
				pv:PivotTo(
					applyAxisTransform(
						currentPivot,
						CFrame.new(currentPivot.Position) * root.CFrame.Rotation,
						pv,
						useX,
						useY,
						useZ
					)
				)
			elseif mode == "PivotToCharacter" then
				pv:PivotTo(
					applyAxisTransform(
						CFrame.new(root.Position) * currentPivot.Rotation,
						CFrame.new(root.Position) * root.CFrame.Rotation,
						pv,
						useX,
						useY,
						useZ
					)
				)
			elseif mode == "LookAtCharacter" then
				pv:PivotTo(
					applyAxisTransform(
						currentPivot,
						CFrame.lookAt(currentPivot.Position, root.Position),
						pv,
						useX,
						useY,
						useZ
					)
				)
			end
		end
	end

	wth:schedule(updateFollowCharacterParts)
end

return mech
