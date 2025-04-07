--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

-- This shapes the Mechanic's attributes.
-- To add new attributes, add a new `key: value` pair, where key is what to
-- name the attribute, and value is the type of said attribute. Value is
-- anything that can be used in instance attributes.
--
-- For consistency, rename this to "MechanicNameAttributes".
type TemplateAttributes = {
	Goat: string,
}

-- This shapes the Mechanic's instance itself.
-- To define children, intersect it with a table, ie.
--
-- ```luau
-- type TemplateInstance = BasePart & {
--     SurfaceGui: SurfaceGui & {
--         TextLabel: TextLabel,
--     },
-- }
-- ```
--
-- For consistency, rename this to "MechanicNameInstance".
type TemplateInstance = BasePart

-- Welcome to Hell requires a Mechanic.
-- The type tells Luau what this Mechanic attributes and instance should be.
local self = {} :: utils.Mechanic<TemplateAttributes, TemplateInstance>

-- Keep this as "Mechanic".
self.type = "Mechanic"

-- This is what to name your Mechanic.
-- The Mechanic will be assigned to the CollectionService tag
-- "Mechanic:(mechanic name)"
self.name = "Template"

-- TBA
-- See the osyrisrblx/t documentation:
-- https://github.com/osyrisrblx/t?tab=readme-ov-file
self.attributes = {
	Goat = utils.t.string,
}

-- TBA
self.defaultAttributes = {
	Goat = "ImNotFireMan123",
}

-- TBA
-- See the osyrisrblx/t documentation:
-- https://github.com/osyrisrblx/t?tab=readme-ov-file
self.instanceCheck = utils.t.instanceIsA("BasePart")

-- Code before self:mechanize will be shared across every instance of this
-- Mechanic.

-- TBA
function self:mechanize(ctx)
	-- Code contained here will be scoped to one instance of this Mechanic.
end

return self
