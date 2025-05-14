--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local function createDefaultClickDetector(trove: std.Trove, btn: BasePart)
	local clickDetector = trove:add(Instance.new("ClickDetector"))
	clickDetector.Name = "ButtonClickDetector"
	clickDetector.Parent = btn

	return clickDetector
end

return createDefaultClickDetector
