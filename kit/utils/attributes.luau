--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("./packages/t")

-- ew... metatables...
export type InstanceAttribute<T> = typeof(setmetatable(
	{} :: {
		name: string,
		check: t.check<T>?,
		defaultValue: T?,
		get: (self: InstanceAttribute<T>, instance: Instance) -> T,
		assert: (self: InstanceAttribute<T>, instance: Instance) -> typeof(assert((nil :: any) :: T, "Luau")),
	},
	{} :: {
		__tostring: (self: InstanceAttribute<T>) -> string,
		__call: (self: InstanceAttribute<T>, instance: Instance) -> T,
	}
))

local function getAttribute(self: InstanceAttribute<any>, instance: Instance)
	local value = instance:GetAttribute(self.name)
	if value == nil or (self.check and not self.check(value)) then
		instance:SetAttribute(self.name, self.defaultValue)
		return self.defaultValue
	end
	return value
end

local function assertAttribute(self: InstanceAttribute<any>, instance: Instance)
	return assert(getAttribute(self, instance), `No attribute "{self.name}" set in {instance:GetFullName()}.`)
end

local mt = table.freeze({
	__tostring = function(self: InstanceAttribute<any>)
		return `InstanceAttribute({self.name})`
	end,
	__call = getAttribute,
})

local function attribute<T>(name: string, check: t.check<T>, defaultValue: T?): InstanceAttribute<T?>
	return table.freeze(setmetatable({
		name = name,
		check = check,
		defaultValue = defaultValue,
		get = getAttribute,
		assert = assertAttribute,
	}, mt))
end

return {
	attribute = (
			attribute :: any
		) :: (<T>(attributeName: string, check: t.check<T>) -> InstanceAttribute<T?>) & (<T>(attributeName: string, check: t.check<T>, defaultValue: T) -> InstanceAttribute<T>),
}
