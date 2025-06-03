--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("../packages/t")
local types = require("../types")

--- @class AttributeGroup
--- Groups of Roblox Instance attributes that share a common prefix. Useful
--- for creating property tables such as `Dismounts` in Dismounters.
export type AttributeGroup<T> =
	& ((instance: Instance) -> types.Map<string, T>)
	& typeof(setmetatable({} :: { prefix: string, pattern: string, check: t.check<T>? }, {} :: AttributeGroupMt))

type AttributeGroupMt = {
	__index: AttributeGroupMt,
	__tostring: <T>(self: AttributeGroup<T>) -> string,
	get: <T>(self: AttributeGroup<T>, instance: Instance) -> types.Map<string, T>,
	changed: <T>(
		self: AttributeGroup<T>,
		instance: Instance,
		callback: (key: string, value: T) -> ()
	) -> RBXScriptConnection,
}

local mt = {} :: AttributeGroupMt
mt.__index = mt

--- @function __tostring
--- @within AttributeGroup
---
--- Metamethod to transform the option into a string.
---
--- @param self AttributeGroup<T> -- The attribute to stringify.
--- @return string -- The string representation of the attribute.
function mt:__tostring<T>()
	return `AttributeGroup({self.prefix})`
end

--- @function get
--- @within AttributeGroup
---
--- Returns all values with from attributes with the given prefix from the given
--- instance. If `config.typecheck` is enabled, values are checked against the
--- attribute's type.
---
--- @param self AttributeGroup<T> -- The attribute.
--- @param instance Instance -- The instance to get the attribute from.
--- @return std.Map<string, T> -- All values.
function mt:get<T>(instance)
	local collected: types.Map<string, T> = {}
	for attributeName, value in instance:GetAttributes() do
		local key = attributeName:match(self.pattern)
		if key then
			if self.check and not self.check(value) then
				continue
			end
			collected[key] = value :: T
		end
	end
	return collected :: any
end

--- @function __call
--- @within AttributeGroup
---
--- Syntax sugar for `AttributeGroup:get(instance)`.
---
--- @param self AttributeGroup<T> -- The attribute.
--- @param instance Instance -- The instance to get the attribute from.
--- @return std.Map<string, T> -- All values.
(mt :: any).__call = mt.get

--- @function changed
--- @within AttributeGroup
---
--- Connects a callback function to be invoked when any of the attributes
--- tracked by this `AttributeGroup` change on an instance.
--- The callback will receive the extracted key and the new value of the changed
--- attribute.
---
--- @param self AttributeGroup<T> -- The attribute.
--- @param instance Instance -- The instance to track the attribute.
--- @param callback (key: string, value: T) -> () -- A function to call when a relevant attribute changes, receiving the key and the new value.
--- @return RBXScriptConnection -- Can be used to disconnect the callback.
function mt:changed<T>(instance, callback)
	return instance.AttributeChanged:Connect(function(attributeName)
		local key = attributeName:match(self.pattern)
		if key then
			local value = instance:GetAttribute(attributeName)
			if self.check and not self.check(value) then
				return
			end
			callback(key, value :: any)
		end
	end)
end

table.freeze(mt)

--- @function AttributeGroup
--- @within attributes
---
--- Creates a new `AttributeGroup` object with the name, an optional typechecker,
--- and an optional pattern.
---
--- @param prefix string -- The common prefix for all attributes in this group (e.g., "Property", "Dismounts").
--- @param check t.check<T> -- An optional `t.check` function to validate the type of each attribute's value within this group.
--- @param pattern string? -- An optional string pattern to extract a unique key from the attribute name. Defaults to `^{prefix}_(%w+)`, which captures word characters after the prefix and an underscore.
--- @return AttributeGroup<T> -- A new `AttributeGroup` object.
local function AttributeGroup<T>(prefix: string, check: t.check<T>, pattern: string?): AttributeGroup<T>
	return table.freeze(setmetatable({
		prefix = prefix,
		pattern = pattern or `^{prefix}_(%w+)`,
		check = check,
	}, mt)) :: any
end

return AttributeGroup
