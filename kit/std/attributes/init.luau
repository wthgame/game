--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Attribute = require("@self/Attribute")
local ManyAttribute = require("@self/ManyAttribute")

export type Attribute<T> = Attribute.Attribute<T>
export type ManyAttribute<T> = ManyAttribute.ManyAttribute<T>

--- @class attributes
--- Implements typechecking instance attributes.
local attributes = {}

attributes.Attribute = Attribute
attributes.ManyAttribute = ManyAttribute

return table.freeze(attributes)
