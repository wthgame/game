--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require(script.CullThrottle)
local character = require(script.character)
local checks = require(script.checks)
local jecs = require(script.jecs)
local t = require(script.t)
local types = require(script.types)

export type Mechanic = types.Mechanic
export type MechanicComponent<Attributes, Instance> = types.MechanicComponent<Attributes, Instance>
export type TouchConfig = types.TouchConfig

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

return table.freeze({
	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacterAlive = character.isCharacterAlive,

	checkTouched = checks.checkTouched,

	createMechanic = function(name: string, attach: (wth: types.WthApi) -> ()): Mechanic
		return table.freeze({
			type = "Mechanic" :: "Mechanic",
			name = name,
			attach = attach,
		})
	end,

	CullThrottle = CullThrottle,

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),

	--- The Entity Component System used in Welcome to Hell.
	--- See: https://github.com/Ukendio/jecs
	jecs = table.freeze(jecs),
})
