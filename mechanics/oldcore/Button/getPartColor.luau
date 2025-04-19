local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local function getPartColor(part: BasePart): Color3
	return utils.roundColor(utils.castCheck(part:GetAttribute("Color3"), utils.t.Color3) or part.Color)
end

return getPartColor
