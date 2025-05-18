--!strict

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local t = require("./packages/t")
local trove = require("./packages/trove")
local types = require("./types")

type TagInstanceCallback<T> = (trove: trove.Trove, instance: T) -> ()
type TagEventCallback<T, Args...> = (trove: trove.Trove, Args...) -> ()

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
	--- the physics state. If no instances are being observed, this event
	--- disconnects, until a new instance is observed, when it will be
	--- reconnected.
	---
	--- @param self Tag<T: Instance> -- TBA
	--- @param callback (instance: T, dt: number, trove: trove.Trove) -> () -- TBA
	--- @return () -> () -- When called, removes the callback from the lifecycle event
	onPreSimulation: (self: Tag<T>, callback: TagEventCallback<T, number>) -> () -> (),
	onPostSimulation: (self: Tag<T>, callback: TagEventCallback<T, number>) -> () -> (),
	onPreRender: (self: Tag<T>, callback: TagEventCallback<T, number>) -> () -> (),
	onPreAnimation: (self: Tag<T>, callback: TagEventCallback<T, number>) -> () -> (),
	onRenderStep: (self: Tag<T>, callback: TagEventCallback<T, number>, priority: number?) -> () -> (),

	trove: trove.Trove,
	destroy: (self: Tag<T>) -> (),
}

type AnyTag = Tag<any>

local SHOULD_OBSERVE_TAG = "__EXTREMELY_DANGEROUS_doNotRemove__wthShouldObserve"

local tagTroves: types.Map<AnyTag, trove.Trove> = {}
local addedCallbacks: types.Map<AnyTag, { TagInstanceCallback<unknown> }> = {}
local allTaggedInstanceTroves: types.Map<AnyTag, types.Map<Instance, trove.Trove>> = {}

--- @class KitStdTags
--- Implements tracking CollectionService tags.
local tags = {}

--- @prop SHOULD_OBSERVE_TAG string
--- @within KitStdTags
--- @internal
--- A tag that is added when a kit object should be observed.
tags.SHOULD_OBSERVE_TAG = SHOULD_OBSERVE_TAG

local function startObservingTag(self: Tag<any>)
	local callbacks = addedCallbacks[self]
	if not callbacks then
		callbacks = {}
		addedCallbacks[self] = callbacks
	end

	local tag = self.tag
	local allInstanceTroves = allTaggedInstanceTroves[self]
	if not allInstanceTroves then
		allInstanceTroves = {}
		allTaggedInstanceTroves[self] = allInstanceTroves
	end

	local function implementTag(instance)
		local instanceTrove = self.trove:extend()
		-- attachToInstance already binds to Instance.Destroying, so we
		-- don't have to worry about that
		instanceTrove:attachToInstance(instance)
		for _, added in callbacks do
			task.spawn(added, instanceTrove, instance)
		end
		allInstanceTroves[instance] = instanceTrove
	end

	self.trove:add(CollectionService:GetInstanceAddedSignal(SHOULD_OBSERVE_TAG):Connect(function(instance)
		if instance:HasTag(tag) then
			implementTag(instance)
		end
	end))

	self.trove:add(CollectionService:GetInstanceRemovedSignal(SHOULD_OBSERVE_TAG):Connect(function(instance)
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

local function createSignalLifecycle<Args...>(signal: RBXScriptSignal)
	local num = 0
	local callbacks: types.Map<TagEventCallback<any, Args...>, AnyTag> = {}
	local connection: RBXScriptConnection?

	local function updateConnection()
		if num > 0 then
			connection = signal:Connect(function(...)
				for callback, self: AnyTag in callbacks :: any do
					task.spawn(callback, trove, ...)
				end
			end)
		elseif connection then
			connection:Disconnect()
			connection = nil
		end
	end

	local function connect<T>(self: Tag<T>, callback: TagEventCallback<any, Args...>)
		num += 1
		callbacks[callback] = self
		updateConnection()

		local function disconnect()
			if callbacks[callback] then
				callbacks[callback] = nil
				num -= 1
				updateConnection()
			end
		end

		return tagTroves[self]:add(disconnect)
	end
	return connect
end

local onPreSimulation = createSignalLifecycle(RunService.PreSimulation)
local onPostSimulation = createSignalLifecycle(RunService.PostSimulation)
local onPreRender = createSignalLifecycle(RunService.PreSimulation)
local onPreAnimation = createSignalLifecycle(RunService.PreAnimation)

local function onRenderStep()
	error("not yet implemented")
end

--- @within KitStdTagged
--- Observes a CollectionService tag that should be observed.
function tags.observeTag<T>(tag: string, check: t.check<T>?, tagTrove: trove.Trove?): Tag<T>
	local trove = tagTrove or trove.Trove.new()
	local self: Tag<T> = {
		type = "Tag",
		tag = tag,
		check = check or t.Instance,

		get = get,

		onAdded = onAdded,
		onActivated = onActivated,

		onPreSimulation = onPreSimulation,
		onPostSimulation = onPostSimulation,
		onPreRender = onPreRender,
		onPreAnimation = onPreAnimation,
		onRenderStep = onRenderStep,

		trove = trove,
		destroy = function()
			trove:clean()
		end,
	} :: any
	tagTroves[self] = self.trove
	task.spawn(startObservingTag, self)
	table.freeze(self)
	return self
end

return table.freeze(tags)
