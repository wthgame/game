--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TemplateAttributes = {}

local function init(wth: utils.WTH)
	local Template = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Template (no comments)",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {},
		attributeChecks = {},
	} :: utils.Mechanic<BasePart, TemplateAttributes>

	wth.registerMechanic(Template)
end

return init
