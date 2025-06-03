--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("../packages/t")
local types = require("../types")

-- Peak Luau
export type ManyAttribute<T> =
	& (() -> types.Map<string, T>)
	& typeof(setmetatable({} :: { prefix: string, pattern: string, check: t.check<T>? }, {} :: ManyAttributeMt))

type ManyAttributeMt = {
	__index: ManyAttributeMt,
	__tostring: <T>(self: ManyAttribute<T>) -> string,
	__call: <T>(self: ManyAttribute<T>, instance: Instance) -> types.Map<string, T>,
	get: <T>(self: ManyAttribute<T>, instance: Instance) -> types.Map<string, T>,
	changed: <T>(
		self: ManyAttribute<T>,
		instance: Instance,
		callback: (key: string, value: T) -> ()
	) -> RBXScriptConnection,
}

local mt = {} :: ManyAttributeMt
mt.__index = mt

function mt:__tostring<T>()
	return `ManyAttribute({self.prefix})`
end

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

mt.__call = mt.get

local function ManyAttribute<T>(prefix: string, check: t.check<T>, pattern: string?): ManyAttribute<T>
	return table.freeze(setmetatable({
		prefix = prefix,
		pattern = pattern or `^{prefix}_(%w+)`,
		check = check,
	}, mt)) :: any
end

return ManyAttribute
