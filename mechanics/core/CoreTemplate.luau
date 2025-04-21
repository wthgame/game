--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type CoreTemplateAttributes = {}

local function init(wth: utils.WTH)
	local CoreTemplate = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "CoreTemplate",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {},
		attributeChecks = {},
	} :: utils.Mechanic<BasePart, CoreTemplateAttributes>

	wth.registerMechanic(CoreTemplate)
end

return init
