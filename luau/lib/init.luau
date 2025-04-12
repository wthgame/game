--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Attributes = require(script.Attributes)
local Character = require(script.Character)
local Checks = require(script.Checks)
local CullThrottle = require(script.CullThrottle)
local Jecs = require(script.Jecs)
local t = require(script.t)
local types = require(script.Types)

export type Mechanic = types.Mechanic
export type TouchConfig = types.TouchConfig

export type Archetype = Jecs.Archetype
export type Archetypes = Jecs.Archetypes
export type ComponentIndex = Jecs.ComponentIndex
export type ComponentRecord = Jecs.ComponentRecord
export type Entity<T = unknown> = Jecs.Entity<T>
export type EntityIndex = Jecs.EntityIndex
export type Id<T = unknown> = Jecs.Id<T>
export type Item<T...> = Jecs.Item<T...>
export type Iter<T...> = Jecs.Iter<T...>
export type Observable = Jecs.Observable
export type Observer = Jecs.Observer
export type Pair<P, O> = Jecs.Pair<P, O>
export type Query<T...> = Jecs.Query<T...>
export type QueryInner = Jecs.QueryInner
export type Record = Jecs.Record
export type World = Jecs.World

export type CullThrottle = CullThrottle.CullThrottle

return table.freeze({
	-- Attributes
	createAttributeReconciler = Attributes.createAttributeReconciler,

	-- Character
	getMaybeCharacter = Character.getMaybeCharacter,
	waitForCharacter = Character.waitForCharacter,
	getCharacter = Character.getCharacter,
	getMaybeHumanoidRootPart = Character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = Character.getHumanoidRootPart,
	getMaybeHumanoid = Character.getMaybeHumanoid,
	getHumanoid = Character.getHumanoid,
	isCharacterAlive = Character.isCharacterAlive,

	-- Checks
	checkTouched = Checks.checkTouched,

	-- Packages
	Jecs = Jecs,
	t = t,
	CullThrottle = CullThrottle,
})
