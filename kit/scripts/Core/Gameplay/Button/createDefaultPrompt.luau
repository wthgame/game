--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local function createDefaultPrompt(trove: std.Trove, btn: BasePart)
	local promptAttachment = trove:add(Instance.new("Attachment"))
	promptAttachment.Name = "ButtonPromptAttachment"

	local prompt = trove:add(Instance.new("ProximityPrompt"))
	prompt.Name = "ButtonProximityPrompt"
	prompt.ActionText = "Activate"
	prompt.RequiresLineOfSight = false

	prompt.Parent = btn
	promptAttachment.Parent = btn

	return prompt
end

return createDefaultPrompt
