--!strict

-- We write the MechanicLib in Luau to enable using Luau type definitions
-- Inspired by http://github.com/znotfireman/jtoh-kit

local Players = game:GetService("Players")

local character = require(script.character)
local checks = require(script.checks)
local geometry = require(script.geometry)
local jecs = require(script.jecs)
local t = require(script.t)
local types = require(script.types)

export type Mechanic<Attributes, Instance, Methods = {}> = types.Mechanic<Attributes, Instance, Methods>
export type MechanizeContext<Attributes, Instance> = types.MechanizeContext<Attributes, Instance>
export type Character = types.Character
export type TouchConfig = types.TouchConfig
export type Trove = types.Trove
export type TroveTrackable = types.TroveTrackable

export type JecsArchetype = jecs.Archetype
export type JecsArchetypes = jecs.Archetypes
export type JecsComponentIndex = jecs.ComponentIndex
export type JecsComponentRecord = jecs.ComponentRecord
export type JecsEntity<T = unknown> = jecs.Entity<T>
export type JecsEntityIndex = jecs.EntityIndex
export type JecsId<T = unknown> = jecs.Id<T>
export type JecsItem<T...> = jecs.Item<T...>
export type JecsIter<T...> = jecs.Iter<T...>
export type JecsObservable = jecs.Observable
export type JecsObserver = jecs.Observer
export type JecsPair<P, O> = jecs.Pair<P, O>
export type JecsQuery<T...> = jecs.Query<T...>
export type JecsQueryInner = jecs.QueryInner
export type JecsRecord = jecs.Record
export type JecsWorld = jecs.World

local utils = table.freeze({
	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacterAlive = character.isCharacterAlive,

	checkTouched = checks.checkTouched,

	getRandomPointInBox = geometry.getRandomPointInBox,
	getRandomPointInSphere = geometry.getRandomPointInSphere,
	isPointInObject = geometry.isPointInObject,

	localPlayer = Players.LocalPlayer,

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),

	--- The Entity Component System used in Welcome to Hell.
	--- See: https://github.com/Ukendio/jecs
	jecs = table.freeze(jecs),
})

return utils
