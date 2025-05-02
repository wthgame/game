local types = require("../types")

export type MapArray<K, T> = {
	get: (self: MapArray<K, T>, key: K) -> { T },
	add: (self: MapArray<K, T>, key: K, value: T) -> T,
	remove: (self: MapArray<K, T>, key: K, value: T) -> T,
	inner: (self: MapArray<K, T>) -> { [K]: { T } },
}

local innerMapArrays: types.Map<MapArray<any, any>, types.Map<any, { any }>> = {}

local function get<K, T>(self: MapArray<K, T>, key: K): { T }
	local existing = innerMapArrays[self][key]
	if not existing then
		local new = {}
		innerMapArrays[self][key] = new
		return new
	end
	return existing
end

local function add<K, T>(self: MapArray<K, T>, key: K, value: T): T
	table.insert(get(self, key), value)
	return value
end

local function remove<K, T>(self: MapArray<K, T>, key: K, value: T): T
	local innerSelf = get(self, key)
	local index = table.find(innerSelf, value)
	if index then
		table.remove(innerSelf, index)
	end
	return value
end

local function inner<K, T>(self: MapArray<K, T>): types.Map<K, { T }>
	return innerMapArrays[self]
end

local function MapSet<K, T>(): MapArray<K, T>
	local self: MapArray<K, T> = table.freeze({
		get = get,
		add = add,
		remove = remove,
		inner = inner,
	}) :: any
	innerMapArrays[self] = {}
	return self
end

return MapSet
