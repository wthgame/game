--[=[
    @within MechanicUtils
    @tag Color
]=]
local function roundColor(color: Color3): Color3
	return Color3.fromRGB(
		math.floor((color.R * 255) + 0.5),
		math.floor((color.G * 255) + 0.5),
		math.floor((color.B * 255) + 0.5)
	)
end

return {
	roundColor = roundColor,
}
