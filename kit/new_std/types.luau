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

return nil
