local types = require("./types")

local instanceIds: types.Map<types.InstanceByIds<any, any>, types.Map<any, types.Set<any>>> = {}

local function getAll<T, I>(self: types.InstanceByIds<T, I>): types.Map<I, types.Set<T>>
	return instanceIds[self] or {}
end

local function getId<T, I>(self: types.InstanceByIds<T, I>, id: I): types.Set<T>
	local selfInstanceIds = instanceIds[self]
	assert(selfInstanceIds, "tried to track destroyed InstanceIds")
	return selfInstanceIds[id] or {}
end

local function add<T, I>(self: types.InstanceByIds<T, I>, instance: T, id: I): T
	local selfInstanceIds = instanceIds[self]
	assert(selfInstanceIds, "tried to track destroyed InstanceIds")
	local ids = selfInstanceIds[id] or {}
	ids[instance] = true
	selfInstanceIds[id] = ids
	return instance
end

local function remove<T, I>(self: types.InstanceByIds<T, I>, instance: T, id: I): T
	local selfInstanceIds = instanceIds[self]
	assert(selfInstanceIds, "tried to track destroyed InstanceIds")
	local ids = selfInstanceIds[id]
	if ids then
		ids[instance] = nil
	end
	return instance
end

local function destroy<T, I>(self: types.InstanceByIds<T, I>)
	local selfInstanceIds = instanceIds[self]
	if selfInstanceIds then
		for _, instances in selfInstanceIds do
			table.clear(instances)
		end
		table.clear(selfInstanceIds)
		instanceIds[self] = nil
	end
end

local function trackInstanceByIds<T, I>(): types.InstanceByIds<T, I>
	local self: types.InstanceByIds<T, I> = table.freeze({
		getAll = getAll,
		getId = getId,
		add = add,
		remove = remove,
		destroy = destroy,
	} :: any)
	instanceIds[self] = {}
	return self
end

return {
	trackInstanceByIds = trackInstanceByIds,
}

--[[

    {
	getInstancesOfId: (id: I) -> Set<T>,
	addInstanceToId: (instance: T, id: I) -> (),
	removeInstanceFromId: (instance: T, id: I) -> (),
    }
]]
