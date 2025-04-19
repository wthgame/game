--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local jecs = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("WTHShared")
		:WaitForChild("include")
		:WaitForChild("node_modules")
		:WaitForChild("@rbxts")
		:WaitForChild("jecs")
		:WaitForChild("jecs")
)

export type Archetype = jecs.Archetype
export type Archetypes = jecs.Archetypes
export type ComponentIndex = jecs.ComponentIndex
export type ComponentRecord = jecs.ComponentRecord
export type Entity<T = unknown> = jecs.Entity<T>
export type EntityIndex = jecs.EntityIndex
export type Id<T = unknown> = jecs.Id<T>
export type Item<T...> = jecs.Item<T...>
export type Iter<T...> = jecs.Iter<T...>
export type Observable = jecs.Observable
export type Observer = jecs.Observer
export type Pair<P, O> = jecs.Pair<P, O>
export type Query<T...> = jecs.Query<T...>
export type QueryInner = jecs.QueryInner
export type Record = jecs.Record
export type World = jecs.World

return jecs
