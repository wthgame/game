--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Attribute = require("@self/Attribute")
local AttributeGroup = require("@self/AttributeGroup")

export type Attribute<T> = Attribute.Attribute<T>
export type AttributeGroup<T> = AttributeGroup.AttributeGroup<T>

--- @class attributes
--- Implements typechecking instance attributes.
local attributes = {}

attributes.Attribute = Attribute
attributes.AttributeGroup = AttributeGroup

return table.freeze(attributes)
