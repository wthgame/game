--!strict

local t = require("./packages/t")
local trove = require("./packages/trove")

export type Map<K, V> = { [K]: V }
export type Set<T> = { [T]: true }

-- ew... metatables...
export type InstanceAttribute<T> = typeof(setmetatable(
	{} :: {
		name: string,
		check: t.check<T>?,
		default: T?,
		get: (self: InstanceAttribute<T>, instance: Instance) -> T,
		assert: (self: InstanceAttribute<T>, instance: Instance) -> typeof(assert((nil :: any) :: T, "Luau")),
		set: (self: InstanceAttribute<T>, instance: Instance, value: T) -> T,
	},
	{} :: {
		__tostring: (self: InstanceAttribute<T>) -> string,
		__call: (self: InstanceAttribute<T>, instance: Instance) -> T,
	}
))

export type TagMethods<T> = {
	get: (self: TagMethods<T>) -> { T },
	added: (self: TagMethods<T>, callback: (instance: T, trove: trove.Trove) -> ()) -> () -> (),
	activated: (self: TagMethods<T>, callback: (instance: T, trove: trove.Trove) -> ()) -> () -> (),
}

local prelude = {
	attribute = function<T>(name: string, attributeCheck: t.check<T>): InstanceAttribute<T>
		return nil :: any
	end,
	tagged = function<T, Self>(props: {
		tag: string,
		check: t.check<T>,
		new: (self: TagMethods<T>) -> Self,
	}): Self
		return nil :: any
	end,
	getMaybeHumanoid = function(): Humanoid
		return nil :: any
	end,
	isBasePart = t.instanceIsA("BasePart") :: t.check<BasePart>,
	isPositiveNumber = t.numberMin(0),
}

local Tripper = prelude.tagged({
	tag = "Tripper",
	check = prelude.isBasePart,
	new = function(tag)
		local self = {}
		self.tag = tag
		self.debounced = {} :: Set<BasePart>
		self.cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber)

		function self.trip(instance)
			if not self.debounced[instance] then
				local humanoid = prelude.getMaybeHumanoid() :: Humanoid
				humanoid.Sit = true
				self.debounced[instance] = true
				task.delay(self.cooldown(instance), function(instance)
					self.debounced[instance] = nil
				end, instance)
			end
		end

		tag:added(self.trip)
		return self
	end,
})

return Tripper
