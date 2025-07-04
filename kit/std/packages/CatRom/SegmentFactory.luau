-- Creates spline segments with minimal repeat computations
-- Fast-tracks special values of alpha and tension
-- Parametrizes following https://qroph.github.io/2018/07/30/smooth-paths-using-catmull-rom-splines.html

local Constants = require("./Constants")
local Segment = require("./Segment")
local Types = require("./Types")
local Utils = require("./Utils")

-- Fast track for tension = 1
local function createTautSegments(
	positions: { Types.Point },
	pointType: Types.PointType,
	quats: { Types.Quaternion }?
): { Types.Segment }
	local p1, p2 = positions[2], positions[3]

	local q0, q1, q2, q3
	if quats then
		q0, q1, q2, q3 = quats[1], quats[2], quats[3], quats[4]
	end

	local segments = table.create(#positions - 3)
	local segmentIndex = 1

	-- Create first segment
	local p21 = p2 - p1
	local a = -2 * p21
	local b = 3 * p21
	local zero = p1 * 0
	segments[1] = Segment.new(a, b, zero, p1, pointType, q0, q1, q2, q3, Utils.Magnitude(p21))

	for i = 4, #positions - 1 do
		-- Slide window
		p1, p2 = p2, positions[i]

		if quats then
			q0, q1, q2, q3 = q1, q2, q3, quats[i]
		end

		segmentIndex += 1

		-- Create segment
		p21 = p2 - p1
		a = -2 * p21
		b = 3 * p21
		segments[segmentIndex] = Segment.new(a, b, zero, p1, pointType, q0, q1, q2, q3, Utils.Magnitude(p21))
	end

	return segments
end

-- Fast track for alpha = 0
local function createUniformSegments(
	positions: { Types.Vector },
	tension: number,
	pointType: Types.PointType,
	quats: { Types.Quaternion }?
): { Types.Segment }
	local p0, p1, p2, p3 = positions[1], positions[2], positions[3], positions[4]

	local p10 = p1 - p0
	local p21 = p2 - p1
	local p32 = p3 - p2

	local scalar = 1 - tension
	local m1 = scalar * (p10 - (p2 - p0) / 2 + p21)
	local m2 = scalar * (p21 - (p3 - p1) / 2 + p32)

	local q0, q1, q2, q3
	if quats then
		q0, q1, q2, q3 = quats[1], quats[2], quats[3], quats[4]
	end

	local segments = table.create(#positions - 3)
	local segmentIndex = 1

	-- Create first segment
	local a = -2 * p21 + m1 + m2
	local b = 3 * p21 - 2 * m1 - m2
	segments[1] = Segment.new(a, b, m1, p1, pointType, q0, q1, q2, q3)

	for i = 5, #positions do
		-- Slide window
		p0, p1, p2, p3 = p1, p2, p3, positions[i]
		p21, p32 = p32, p3 - p2
		m1, m2 = m2, scalar * (p21 - (p3 - p1) / 2 + p32)

		if quats then
			q0, q1, q2, q3 = q1, q2, q3, quats[i]
		end

		segmentIndex += 1

		-- Create segment
		a = -2 * p21 + m1 + m2
		b = 3 * p21 - 2 * m1 - m2
		segments[segmentIndex] = Segment.new(a, b, m1, p1, pointType, q0, q1, q2, q3)
	end

	return segments
end

-- General parametrization method
local function createSegments(
	positions: { Types.Vector },
	distances: { number },
	tension: number,
	pointType: Types.PointType,
	quats: { Types.Quaternion }?
): { Types.Segment }
	local p0, p1, p2, p3 = positions[1], positions[2], positions[3], positions[4]

	local p10 = p1 - p0
	local p21 = p2 - p1
	local p32 = p3 - p2
	local p20 = p2 - p0
	local p31 = p3 - p1

	local p10Mag = distances[1]
	local p21Mag = distances[2]
	local p32Mag = distances[3]

	local p10Normalized = p10 / p10Mag
	local p21Normalized = p21 / p21Mag
	local p32Normalized = p32 / p32Mag

	local coTension = 1 - tension
	local m1 = p10Normalized - p20 / (p10Mag + p21Mag) + p21Normalized
	local m2 = p21Normalized - p31 / (p21Mag + p32Mag) + p32Normalized

	local q0, q1, q2, q3
	if quats then
		q0, q1, q2, q3 = quats[1], quats[2], quats[3], quats[4]
	end

	local segments = table.create(#positions - 3)
	local segmentIndex = 1

	-- Create first segment
	local scalar = coTension * p21Mag
	local scaledM1 = scalar * m1
	local scaledM2 = scalar * m2
	local a = -2 * p21 + scaledM1 + scaledM2
	local b = 3 * p21 - 2 * scaledM1 - scaledM2
	segments[1] = Segment.new(a, b, scaledM1, p1, pointType, q0, q1, q2, q3)

	for i = 5, #positions do
		-- Slide window
		p1, p2, p3 = p2, p3, positions[i]
		p21, p32 = p32, p3 - p2
		p31 = p3 - p1
		p21Mag, p32Mag = p32Mag, distances[i - 1]
		p21Normalized, p32Normalized = p32Normalized, p32 / p32Mag
		m1, m2 = m2, p21Normalized - p31 / (p21Mag + p32Mag) + p32Normalized

		if quats then
			q0, q1, q2, q3 = q1, q2, q3, quats[i]
		end

		segmentIndex += 1

		-- Create segment
		scalar = coTension * p21Mag
		scaledM1, scaledM2 = scalar * m1, scalar * m2
		a = -2 * p21 + scaledM1 + scaledM2
		b = 3 * p21 - 2 * scaledM1 - scaledM2
		segments[segmentIndex] = Segment.new(a, b, scaledM1, p1, pointType, q0, q1, q2, q3)
	end

	return segments
end

-- "Padded" refers to extrapolating for the 0th and n+1th points
local function getPaddedPositionsAndRotations(
	points: { Types.Point },
	loops: boolean,
	pointType: Types.PointType
): ({ Types.Vector }, { Types.Quaternion }?)
	local numPoints = #points
	local firstPoint = points[1]
	local lastPoint = points[numPoints]

	-- Extrapolate to get 0th and n+1th points
	local zerothPos, zerothQuat, veryLastPos, veryLastQuat
	if loops then
		zerothPos, zerothQuat = Utils.SeparatePositionAndRotation(points[numPoints - 1], pointType)
		veryLastPos, veryLastQuat = Utils.SeparatePositionAndRotation(points[2], pointType)
	else
		zerothPos, zerothQuat = Utils.SeparatePositionAndRotation(Utils.Lerp(points[2], firstPoint, 2), pointType)
		veryLastPos, veryLastQuat =
			Utils.SeparatePositionAndRotation(Utils.Lerp(points[numPoints - 1], lastPoint, 2), pointType)
	end

	-- Separate positions and rotations of points (if applicable)
	local positions = table.create(numPoints + 2)
	positions[1] = zerothPos
	positions[numPoints + 2] = veryLastPos
	local quats

	if pointType == "CFrame" then
		quats = table.create(numPoints + 2)
		quats[1] = zerothQuat
		quats[numPoints + 2] = veryLastQuat

		local i = 2
		for _, point in points do
			positions[i] = point.Position
			quats[i] = Utils.CFrameToQuaternion(point)
			i += 1
		end
	else
		table.move(points, 1, numPoints, 2, positions)
	end

	return positions, quats
end

local SegmentFactory = {}

-- Removes adjacent points that are fuzzy-equal
function SegmentFactory.GetUniquePoints(points: { Types.Point }): { Types.Point }
	local prevPoint = points[1]
	local uniquePoints = { prevPoint }
	local i = 2

	for j = 2, #points do
		local point = points[j]
		if not Utils.FuzzyEq(point, prevPoint, Constants.MACHINE_EPSILON) then
			uniquePoints[i] = point
			i += 1
			prevPoint = point
		end
	end

	return uniquePoints
end

function SegmentFactory.CreatePointSegment(point: Types.Point, pointType: Types.PointType): Types.Segment
	local pos, quat = Utils.SeparatePositionAndRotation(point, pointType)
	local zero = pos * 0

	return Segment.new(zero, zero, zero, pos, pointType, quat, nil, nil, nil, 0)
end

function SegmentFactory.CreateLineSegment(
	point1: Types.Point,
	point2: Types.Point,
	pointType: Types.PointType
): Types.Segment
	local point0 = Utils.Lerp(point2, point1, 2)
	local point3 = Utils.Lerp(point1, point2, 2)

	local _, q0 = Utils.SeparatePositionAndRotation(point0, pointType)
	local p1, q1 = Utils.SeparatePositionAndRotation(point1, pointType)
	local p2, q2 = Utils.SeparatePositionAndRotation(point2, pointType)
	local _, q3 = Utils.SeparatePositionAndRotation(point3, pointType)

	local zero = p1 * 0
	local p21 = p2 - p1

	return Segment.new(zero, zero, p21, p1, pointType, q0, q1, q2, q3, Utils.Magnitude(p21))
end

function SegmentFactory.CreateSegments(
	points: { Types.Point },
	alpha: number,
	tension: number,
	loops: boolean,
	pointType: Types.PointType
): { Types.Segment }
	local positions, quats = getPaddedPositionsAndRotations(points, loops, pointType)

	-- Fast tracks
	if tension == 1 then
		return createTautSegments(positions, pointType, quats)
	elseif alpha == 0 then
		return createUniformSegments(positions, tension, pointType, quats)
	end

	-- Compute distances between points with a fast track for alpha = 0.5
	local distances = table.create(#points - 1)
	local prevPos = positions[1]

	if alpha == 0.5 then
		for i = 2, #positions do
			local pos = positions[i]
			distances[i - 1] = math.sqrt(Utils.Magnitude(pos - prevPos))
			prevPos = pos
		end
	else
		for i = 2, #positions do
			local pos = positions[i]
			distances[i - 1] = Utils.Magnitude(pos - prevPos) ^ alpha
			prevPos = pos
		end
	end

	return createSegments(positions, distances, tension, pointType, quats)
end

return SegmentFactory
