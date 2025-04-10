--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TemplateAttributes = {
	Goat: string,
}

type TemplateInstance = BasePart

local self = {} :: utils.Mechanic<TemplateAttributes, TemplateInstance>
self.type = "Mechanic"
self.name = "TemplateNoComment"

self.attributes = {
	Goat = utils.t.string,
}

self.defaultAttributes = {
	Goat = "ImNotFireMan123",
}

self.instanceCheck = utils.t.instanceIsA("BasePart")

function self:mechanize(ctx) end

return self
