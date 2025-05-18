--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local logger = require("./logger")
local t = require("./packages/t")

--- @class KitStdAttributes
--- Implements typechecking instance attributes.
local attributes = {}

local defaultLogger = logger.createLogger("KitStdAttributes")

-- ew... metatables...
export type Attribute<T> = typeof(setmetatable(
	{} :: {
		name: string,
		check: t.check<T>?,
		default: T?,
		get: (self: Attribute<T>, instance: Instance) -> T,
		assert: (self: Attribute<T>, instance: Instance) -> typeof(assert((nil :: any) :: T, "Luau")),
		set: (self: Attribute<T>, instance: Instance, value: T?) -> T,
	},
	{} :: {
		__tostring: (self: Attribute<T>) -> string,
		__call: (self: Attribute<T>, instance: Instance) -> T,
	}
))

local function get(self: Attribute<any>, instance: Instance)
	local value = instance:GetAttribute(self.name)
	if value == nil or (self.check and not self.check(value)) then
		return self.default
	end
	return value
end

local function assert(self: Attribute<any>, instance: Instance, logger: logger.Logger?)
	return (logger or defaultLogger):assert(
		get(self, instance),
		`No attribute "{self.name}" set in {instance:GetFullName()}.`
	)
end

local function set(self: Attribute<any>, instance: Instance, value: any)
	instance:SetAttribute(self.name, value)
	return value
end

local mt = table.freeze({
	__tostring = function(self: Attribute<any>)
		return `Attribute({self.name})`
	end,
	__call = get,
})

--- @function attribute
--- @within KitStdAttributes
---
--- Returns methods to typecheck and get an attribute from an instance.
---
--- @param name string -- The name of the attribute to check
--- @param check t.check<T> -- The typechecker to use.
local function attribute<T>(name: string, check: t.check<T>, default: T?): Attribute<T?>
	return table.freeze(setmetatable({
		name = name,
		check = check,
		default = default,
		get = get,
		assert = assert,
		set = set,
	}, mt))
end

attributes.attribute = attribute :: (
	& (<T>(attributeName: string, check: t.check<T>) -> Attribute<T?>)
	& (<T>(attributeName: string, check: t.check<T>, defaultValue: T) -> Attribute<T>)
)

return table.freeze(attributes)
