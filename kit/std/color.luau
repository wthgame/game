--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

--[=[
    @within KitStd
    @tag Color
]=]
local function roundColor(color: Color3): Color3
	return Color3.fromRGB(
		math.floor((color.R * 255) + 0.5),
		math.floor((color.G * 255) + 0.5),
		math.floor((color.B * 255) + 0.5)
	)
end

local function pickTimeInColorSequence(sequence: ColorSequence, time: number)
	if time == 0 then
		return sequence.Keypoints[1].Value
	elseif time == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end
	for i = 1, #sequence.Keypoints - 1 do
		local thisKeypoint = sequence.Keypoints[i]
		local nextKeypoint = sequence.Keypoints[i + 1]
		if time >= thisKeypoint.Time and time < nextKeypoint.Time then
			local alpha = (time - thisKeypoint.Time) / (nextKeypoint.Time - thisKeypoint.Time)
			return Color3.new(
				(nextKeypoint.Value.R - thisKeypoint.Value.R) * alpha + thisKeypoint.Value.R,
				(nextKeypoint.Value.G - thisKeypoint.Value.G) * alpha + thisKeypoint.Value.G,
				(nextKeypoint.Value.B - thisKeypoint.Value.B) * alpha + thisKeypoint.Value.B
			)
		end
	end
	error("unreachable")
end

return {
	roundColor = roundColor,
	pickTimeInColorSequence = pickTimeInColorSequence,
}
