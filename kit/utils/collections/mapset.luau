local types = require("../types")

export type MapSet<K, T> = {
	get: (self: MapSet<K, T>, key: K) -> { [T]: true },
	add: (self: MapSet<K, T>, key: K, value: T) -> T,
	remove: (self: MapSet<K, T>, key: K, value: T) -> T,
	inner: (self: MapSet<K, T>) -> { [K]: { [T]: true } },
}

local innerMapSets: types.Map<MapSet<any, any>, types.Map<any, types.Set<any>>> = {}

local function get<K, T>(self: MapSet<K, T>, key: K): types.Set<T>
	local existing = innerMapSets[self][key]
	if not existing then
		local new = {}
		innerMapSets[self][key] = new
		return new
	end
	return existing
end

local function add<K, T>(self: MapSet<K, T>, key: K, value: T): T
	get(self, key)[value] = true
	return value
end

local function remove<K, T>(self: MapSet<K, T>, key: K, value: T): T
	get(self, key)[value] = nil
	return value
end

local function inner<K, T>(self: MapSet<K, T>): types.Map<K, types.Set<T>>
	return innerMapSets[self]
end

local function MapSet<K, T>(): MapSet<K, T>
	local self: MapSet<K, T> = table.freeze({
		get = get,
		add = add,
		remove = remove,
		inner = inner,
	}) :: any
	innerMapSets[self] = {}
	return self
end

return MapSet
