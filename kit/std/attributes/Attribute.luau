--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("../packages/t")

--- @class Attribute
---
--- Roblox instance attributes.
export type Attribute<T> =
	& ((instance: Instance) -> T)
	& typeof(setmetatable({} :: { name: string, check: t.check<T>?, default: T? }, {} :: AttributeImpl))

type AttributeImpl = {
	__index: AttributeImpl,
	__tostring: <T>(self: Attribute<T>) -> string,
	get: <T>(self: Attribute<T>, instance: Instance) -> T,
	assert: <T>(self: Attribute<T>, instance: Instance) -> typeof(assert((nil :: any) :: T, "Luau")),
	set: <T>(self: Attribute<T>, instance: Instance, value: T?) -> T,
	changed: <T>(self: Attribute<T>, instance: Instance, callback: (new: T) -> ()) -> RBXScriptConnection,
}

local mt = {} :: AttributeImpl
mt.__index = mt

--- @function __tostring
--- @within Attribute
---
--- Metamethod to transform the option into a string.
---
--- @param self Attribute<T> -- The attribute to stringify.
--- @return string -- The string representation of the attribute.
function mt:__tostring<T>()
	return `Attribute({self.name})`
end

--- @function get
--- @within Attribute
---
--- Returns the value of the attribute from the given instance. If there is no
--- attribute, or `config.typecheck` is enabled and the value does not match the
--- expected type, returns the default value, if any.
---
--- @param self Attribute<T> -- The attribute.
--- @param instance Instance -- The instance to get the attribute from.
--- @return T -- The value of the attribute.
function mt:get<T>(instance: Instance)
	local value = instance:GetAttribute(self.name)
	if value == nil or (self.check and not self.check(value)) then
		return self.default :: any
	end
	return value :: any
end

--- @function __call
--- @within Attribute
---
--- Syntax sugar for `Attribute:get(instance)`.
---
--- @param self Attribute<T> -- The attribute.
--- @param instance Instance -- The instance to get the attribute from.
--- @return T -- The value of the attribute.
(mt :: any).__call = mt.get

--- @function assert
--- @within Attribute
---
--- Asserts that the attribute has a valid value on the given instance.
--- If the attribute is not set or its value is falsy, an error will be thrown.
---
--- @param self Attribute<T> -- The attribute.
--- @param instance Instance -- The instance to get the attribute from.
--- @return T -- The truthy value of the attribute.
function mt:assert<T>(instance: Instance)
	return assert(mt.get(self :: any, instance), `No attribute "{self.name}" set in {instance:GetFullName()}.`)
end

--- @function set
--- @within Attribute
---
--- Sets the value of the attribute on the given instance.
---
--- @param self Attribute<T> -- The attribute.
--- @param instance Instance -- The instance to set the attribute.
--- @param value T? -- The new value to set for the attribute. Can be `nil` to clear the attribute.
--- @return T -- The value that was set.
function mt:set<T>(instance: Instance, value: any)
	instance:SetAttribute(self.name, value)
	return value
end

--- @function changed
--- @within Attribute
---
--- Connects a callback function to be invoked when the attribute's value
--- changes on the given instance. The callback will receive the new value of
--- the attribute.
---
--- @param self Attribute<T> -- The attribute.
--- @param instance Instance -- The instance to track the attribute.
--- @param callback (new: T) -> () -- A function to call when the attribute changes, receiving the new value.
--- @return RBXScriptConnection -- Can be used to disconnect the callback.
function mt:changed<T>(instance: Instance, callback: (new: any) -> ())
	return instance:GetAttributeChangedSignal(self.name):Connect(function()
		callback(self:get(instance))
	end)
end

table.freeze(mt)

--- @function Attribute
--- @within attributes
---
--- Creates a new `Attribute` object with the name, an optional typecheckr, and
--- an optional default value.
---
--- @param name string -- The name of the attribute.
--- @param check t.check<T> -- An optional `t.check` function to validate the type of the attribute's value.
--- @param default T? -- An optional default value for the attribute if it's not set or invalid.
--- @return Attribute<T> -- A new `Attribute` object.
local function Attribute(name: string, check: t.check<unknown>, default: unknown?)
	return table.freeze(setmetatable({
		name = name,
		check = check,
		default = default,
	}, mt))
end

return (Attribute :: any) :: (
	& (<T>(name: string, check: t.check<T>) -> Attribute<T?>)
	& (<T>(name: string, check: t.check<T>, defaultValue: T) -> Attribute<T>)
)
