--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require("./packages/cull-throttle")
local Sift = require("./packages/sift")
local animation = require("./animation")
local assets = require("./assets")
local character = require("./character")
local ecs = require("./ecs")
local effects = require("./effects")
local jecs = require("./packages/jecs")
local t = require("./packages/t")
local touch = require("./touch")
local trove = require("./packages/trove")
local types = require("./types")

export type Mechanic<Self = {}> = types.Mechanic<Self>
export type TouchConfig = types.TouchConfig
export type TweenConfig = types.TweenConfig
export type Character = types.Character

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

export type CullThrottle = CullThrottle.CullThrottle

export type Check<T> = t.Check<T>

export type Trove = trove.Trove
export type TroveTrackable = trove.TroveTrackable

return table.freeze({
	version = table.freeze({ major = 1, minor = 0, patch = 0 }),

	tween = animation.tween,

	assets = assets,

	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacter = character.isCharacter,
	isLocalPlayerCharacter = character.isLocalPlayerCharacter,
	isCharacterAlive = character.isCharacterAlive,

	isCharacterTouchingPart = touch.isCharacterTouchingPart,
	isLocalPlayerCharacterTouchingPart = touch.isLocalPlayerCharacterTouchingPart,
	isTouched = touch.isTouched,
	isPartTouched = touch.isPartTouched,
	getPartTouched = touch.getPartTouched,

	world = ecs.world,
	collectSignal = ecs.collectSignal,

	createRingOfFire = effects.createRingOfFire,

	jecs = jecs,
	t = t,
	CullThrottle = CullThrottle,
	Sift = Sift,
})
