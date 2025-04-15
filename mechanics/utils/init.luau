--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local lib = require(script.lib)

export type Mechanic<Self = {}> = lib.Mechanic<Self>
export type TouchConfig = lib.TouchConfig
export type TweenConfig = lib.TweenConfig
export type Character = lib.Character

export type Archetype = lib.Archetype
export type Archetypes = lib.Archetypes
export type ComponentIndex = lib.ComponentIndex
export type ComponentRecord = lib.ComponentRecord
export type Entity<T = unknown> = lib.Entity<T>
export type EntityIndex = lib.EntityIndex
export type Id<T = unknown> = lib.Id<T>
export type Item<T...> = lib.Item<T...>
export type Iter<T...> = lib.Iter<T...>
export type Observable = lib.Observable
export type Observer = lib.Observer
export type Pair<P, O> = lib.Pair<P, O>
export type Query<T...> = lib.Query<T...>
export type QueryInner = lib.QueryInner
export type Record = lib.Record
export type World = lib.World

export type CullThrottle = lib.CullThrottle

export type Check<T> = lib.Check<T>

export type Trove = lib.Trove
export type TroveTrackable = lib.TroveTrackable

return lib
