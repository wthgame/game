--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CollectionService = game:GetService("CollectionService")

local jecs = require("./packages/jecs")
local t = require("./packages/t")
local types = require("./types")
local world = require("./world")

-- FIXME: luau is mid so had to do bad types
local function trackCollectionServiceTag(tag: string, check: types.Typechecker<any>): any
	assert(t.string(tag))
	assert(t.callback(check))

	local component = world:component()
	world:set(component, jecs.Name, tag)

	local instanceToEntity: { [Instance]: jecs.Entity } = {}
	local function addInstance(instance: Instance)
		if check(instance) then
			local entity = world:entity()
			world:set(entity, component, instance)
			instanceToEntity[instance] = entity
		end
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(addInstance)

	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		local entity = instanceToEntity[instance]
		if entity then
			world:remove(entity, component)
			instanceToEntity[instance] = nil
		end
	end)

	for _, instance in CollectionService:GetTagged(tag) do
		addInstance(instance)
	end

	return component
end

return {
	trackCollectionServiceTag = trackCollectionServiceTag,
}
