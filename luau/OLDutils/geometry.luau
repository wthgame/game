--!strict
--!nolint LocalShadow

-- Based on https://github.com/tenx29/PartEmitter/blob/master/src/Utils.lua

local geometryRandom = Random.new(os.time())

local geometry = {}

function geometry.getRandomPointInSphere(minRadius: number, maxRadius: number, random: Random?): Vector3
	local random = random or geometryRandom
	local radius = random:NextNumber(minRadius, maxRadius)
	local u = random:NextNumber()
	local v = random:NextNumber()
	local theta = u * 2.0 * math.pi
	local phi = math.acos(2.0 * v - 1.0)
	local r

	if minRadius == maxRadius then
		r = radius
	else
		r = (random:NextNumber(minRadius / maxRadius, 1) ^ (1 / 3)) * radius
	end

	local sinTheta = math.sin(theta)
	local cosTheta = math.cos(theta)
	local sinPhi = math.sin(phi)
	local cosPhi = math.cos(phi)
	local x = r * sinPhi * cosTheta
	local y = r * sinPhi * sinTheta
	local z = r * cosPhi
	return Vector3.new(x, y, z)
end

function geometry.getRandomPointInBox(Size: Vector3, BoxCFrame: CFrame?, random: Random?): Vector3
	local random = random or geometryRandom
	local offset = Vector3.new(
		Size.X * random:NextNumber(-0.5, 0.5),
		Size.Y * random:NextNumber(-0.5, 0.5),
		Size.Z * random:NextNumber(-0.5, 0.5)
	)
	if BoxCFrame then
		return (BoxCFrame.RightVector * offset.X + BoxCFrame.UpVector * offset.Y + BoxCFrame.LookVector * offset.Z)
	else
		return offset
	end
end

-- function geometry.getWorldOrientedSurface(part: BasePart, normalId: Enum.NormalId): (CFrame, Vector2)
-- 	local cf = part.CFrame
-- 	local rot = cf - cf.Position

-- 	local nObject = Vector3.fromNormalId(normalId)
-- 	local nWorld = rot * nObject

-- 	-- get orthogonal vector by utilizing the order of NormalId enums
-- 	-- i.e. Front.Value is 5 -> (5+1)%6 = 0 -> Right.Value
-- 	local xWorld = rot * Vector3.fromNormalId((normalId.Value + 1) % 6)

-- 	-- get other orthogonal vector
-- 	local zWorld = nWorld:Cross(xWorld)

-- 	-- make them both point "generally down"
-- 	if xWorld.Y > 0 then
-- 		xWorld = -xWorld
-- 	end
-- 	if zWorld.Y > 0 then
-- 		zWorld = -zWorld
-- 	end

-- 	-- choose the one pointing "more down" one as the z axis for the surface
-- 	if xWorld.Y < zWorld.Y then
-- 		zWorld = xWorld
-- 	end

-- 	-- redefine x axis based on that
-- 	xWorld = nWorld:Cross(zWorld)

-- 	local surfaceRot = CFrame.fromMatrix(Vector3.new(), xWorld, nWorld, zWorld)

-- 	local sizeInWorldSpace = rot * part.Size
-- 	local sizeInSurfaceSpace = surfaceRot:Inverse() * sizeInWorldSpace

-- 	-- get position on surface
-- 	local surfaceCFrame = surfaceRot + cf.Position + nWorld * math.abs(sizeInSurfaceSpace.Y) / 2

-- 	return surfaceCFrame, Vector2.new(math.abs(sizeInSurfaceSpace.X), math.abs(sizeInSurfaceSpace.Z))
-- end

-- function geometry.getRandomPointOnSurface(Part: BasePart, NormalId: Enum.NormalId, random: Random?): Vector3
-- 	local random = random or geometryRandom
-- 	local surfaceCFrame, surfaceSize = geometry.getWorldOrientedSurface(Part, NormalId)
-- 	local surfaceXOffset = surfaceCFrame.RightVector * surfaceSize.X * random:NextNumber(-0.5, 0.5)
-- 	local surfaceYOffset = surfaceCFrame.LookVector * surfaceSize.Y * random:NextNumber(-0.5, 0.5)
-- 	return surfaceCFrame + surfaceXOffset + surfaceYOffset
-- end

-- From EToH MusicModule
function geometry.isPointInObject(point: Vector3, object: BasePart)
	local offset = object.CFrame:PointToObjectSpace(point)

	local insideX = math.abs(offset.X) <= object.Size.X / 2
	local insideY = math.abs(offset.Y) <= object.Size.Y / 2
	local insideZ = math.abs(offset.Z) <= object.Size.Z / 2

	return insideX and insideY and insideZ
end

table.freeze(geometry)
return geometry
