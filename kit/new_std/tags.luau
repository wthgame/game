--!strict

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local t = require("./packages/t")
local trove = require("./packages/trove")
local types = require("./types")

type TagInstanceCallback<T> = (instance: T, trove: trove.Trove) -> ()
type TagSimulationCallback<T> = (instance: T, dt: number, trove: trove.Trove) -> ()

--- @class Tag
--- Methods to interact with tagged objects.
export type Tag<T> = {
	type: "Tag",
	tag: string,
	check: t.check<T>,

	get: (self: Tag<T>) -> { T },

	onAdded: (self: Tag<T>, callback: TagInstanceCallback<T>) -> () -> (),
	onActivated: (self: Tag<T>, callback: TagInstanceCallback<T>) -> () -> (),

	--- @function preSimulation
	--- @within Tag
	---
	--- Calls the given callback every `RunService.PreSimulation`. It is called
	--- after physics has been done and is optimal for responding to changes in
	--- the physics state. If no instances are being observed, this connection
	--- disconnects, until a instance is observed, when it will be reconnected.
	---
	--- @param self Tag<T: Instance> -- TBA
	--- @param callback (instance: T, dt: number, trove: trove.Trove) -> () -- TBA
	--- @return () -> () -- When called, removes the callback from the lifecycle event
	onPreSimulation: (self: Tag<T>, callback: TagSimulationCallback<T>) -> () -> (),
	onPostSimulation: (self: Tag<T>, callback: TagSimulationCallback<T>) -> () -> (),
	onPreRender: (self: Tag<T>, callback: TagSimulationCallback<T>) -> () -> (),
	onPreAnimation: (self: Tag<T>, callback: TagSimulationCallback<T>) -> () -> (),
	onRenderStep: (self: Tag<T>, callback: TagSimulationCallback<T>, priority: number?) -> () -> (),

	trove: trove.Trove,
	destroy: (self: Tag<T>) -> (),
}

type AnyTag = Tag<any>

local SHOULD_OBSERVE_TAG = "__EXTREMELY_DANGEROUS_doNotRemove__wthShouldObserve"

local tagTroves: types.Map<AnyTag, trove.Trove> = {}
local addedCallbacks: types.Map<AnyTag, { TagInstanceCallback<unknown> }> = {}
local preSimulationCallbacks: types.Map<AnyTag, { TagSimulationCallback<unknown> }> = {}
local postSimulationCallbacks: types.Map<AnyTag, { TagSimulationCallback<unknown> }> = {}
local preRenderCallbacks: types.Map<AnyTag, { TagSimulationCallback<unknown> }> = {}
local preAnimationCallbacks: types.Map<AnyTag, { TagSimulationCallback<unknown> }> = {}

--- @class KitStdTags
--- Implements tracking CollectionService tags.
local tags = {}

local function startObservingTag(self: Tag<any>)
	local callbacks = addedCallbacks[self]
	if not callbacks then
		callbacks = {}
		addedCallbacks[self] = callbacks
	end

	local tag = self.tag
	local allInstanceTroves: types.Map<Instance, trove.Trove> = {}

	self.trove:add(CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		if instance:HasTag(SHOULD_OBSERVE_TAG) then
			local instanceTrove = self.trove:extend()
			-- attachToInstance already binds to Instance.Destroying, so we
			-- don't have to worry about that
			instanceTrove:attachToInstance(instance)
			for _, added in callbacks do
				task.spawn(added, instance, instanceTrove)
			end
			allInstanceTroves[instance] = instanceTrove
		end
	end))

	self.trove:add(CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		local trove = allInstanceTroves[instance]
		if trove then
			trove:clean()
		end
	end))
end

local function onAdded<T>(self: Tag<T>, callback: (instance: T, trove: trove.Trove) -> ()): () -> ()
	local callbacks = addedCallbacks[self]
	if not callbacks then
		callbacks = {}
		addedCallbacks[self] = callbacks
	end

	local function wrapped(instance: any, trove: any)
		if self.check(instance) then
			callback(instance, trove)
		end
	end

	table.insert(callbacks, wrapped)

	local function disconnect()
		table.remove(callbacks, table.find(callbacks, wrapped))
	end

	-- TODO: how we do ts :wilting_rose:
	-- task.spawn(function()
	-- 	for _, instance in self:get() do
	-- 		wrapped(instance, where the fuck do i get the trove)
	-- 	end
	-- end)

	return disconnect
end

local function get<T>(self: Tag<T>): { T }
	local filtered = {}
	for _, tagged in CollectionService:GetTagged(self.tag) do
		if tagged:HasTag(SHOULD_OBSERVE_TAG) and self.check(filtered) then
			table.insert(filtered, tagged)
		end
	end
	return filtered
end

local function onActivated<T>(self: Tag<T>, callback: TagInstanceCallback<T>): never
	error("not yet implemented")
end

local function createSignalLifecycle(signal: RBXScriptSignal)
	local num = 0
	return function<T>(self: Tag<T>, callback: TagSimulationCallback<T>)
		-- TODO: hardcode
		num += 1
	end
end

-- local function onPreSimulation<T>(self: Tag<T>, callback: TagSimulationCallback<T>)
-- 	if #self:get() > 0 then
-- 		RunService.PreSimulation:Connect(function(dt) end)
-- 	end
-- end

--- @within KitStdTagged
--- Observes a CollectionService tag that should be observed.
function tags.observeTag<T>(tag: string, check: t.check<T>?, tagTrove: trove.Trove?): Tag<T>
	local self: Tag<T> = {
		type = "Tag",
		tag = tag,
		check = check or t.Instance,
		get = get,
		onAdded = onAdded,
		onActivated = onActivated,

		trove = tagTrove or trove.Trove.new(),
	} :: any
	tagTroves[self] = self.trove
	task.spawn(startObservingTag, self)
	table.freeze(self)
	return self
end

return table.freeze(tags)
