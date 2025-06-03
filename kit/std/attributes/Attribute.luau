--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("../packages/t")

-- Peak Luau
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

function mt:__tostring<T>()
	return `Attribute({self.name})`
end

function mt:get<T>(instance: Instance)
	local value = instance:GetAttribute(self.name)
	if value == nil or (self.check and not self.check(value)) then
		return self.default :: any
	end
	return value :: any
end

(mt :: any).__call = mt.get

function mt:assert<T>(instance: Instance)
	return assert(mt.get(self :: any, instance), `No attribute "{self.name}" set in {instance:GetFullName()}.`)
end

function mt:set<T>(instance: Instance, value: any)
	instance:SetAttribute(self.name, value)
	return value
end

function mt:changed<T>(instance: Instance, callback: (new: any) -> ())
	return instance:GetAttributeChangedSignal(self.name):Connect(function()
		callback(self:get(instance))
	end)
end

table.freeze(mt)

local function Attribute(name: string, check: t.check<unknown>, default: unknown?)
	return table.freeze(setmetatable({
		name = name,
		check = check,
		default = default,
	}, mt))
end

return (Attribute :: any) :: (
	& (<T>(attributeName: string, check: t.check<T>) -> Attribute<T?>)
	& (<T>(attributeName: string, check: t.check<T>, defaultValue: T) -> Attribute<T>)
)
