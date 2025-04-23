--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local function createDefaultClickDetector(trove: utils.Trove, btn: BasePart)
	print(trove)
	local clickDetector = trove:add(Instance.new("ClickDetector"))
	clickDetector.Name = "ButtonClickDetector"
	clickDetector.Parent = btn

	return clickDetector
end

return createDefaultClickDetector
