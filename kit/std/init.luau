--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local activation = require(script.activation)
local animation = require(script.animation)
local assets = require(script.assets)
local attributes = require(script.attributes)
local audio = require(script.audio)
local bindings = require(script.bindings)
local character = require(script.character)
local collections = require(script.collections)
local color = require(script.color)
local lemonSignal = require(script.packages.lemonSignal)
local logger = require(script.logger)
local math = require(script.math)
local never = require(script.never)
local physics = require(script.physics)
local prelude = require(script.prelude)
local sift = require(script.packages.sift)
local t = require(script.packages.t)
local touch = require(script.touch)
local trove = require(script.packages.trove)
local types = require(script.types)

export type Attribute<T> = attributes.Attribute<T>
export type ManyAttribute<T> = attributes.ManyAttribute<T>

export type Map<K, V> = types.Map<K, V>
export type Set<T> = types.Set<T>
export type MapSet<K, T> = collections.MapSet<K, T>
export type MapArray<K, T> = collections.MapArray<K, T>
export type Kit = types.Kit
export type KitScript<Self = {}> = types.KitScript<Self>
export type InstanceTag<I> = types.InstanceTag<I>
export type Character = types.Character
export type PlaySoundConfig = audio.PlaySoundConfig
export type TweenConfig = animation.TweenConfig

export type check<T> = t.check<T>
export type Trove = trove.Trove
export type LemonConnection<U...> = lemonSignal.Connection<U...>
export type LemonSignal<T...> = lemonSignal.Signal<T...>

--- @class KitStd
--- @since 1.0.0
---
--- The Welcome To Hell Kit Standard Library is contains many utilities,
--- including types like Attribute,
--- In addition to the Welcome To Hell API which is bundled as part of the kit,
--- the game also provides this sibling package that contains a set of utilities
--- to streamline common patterns and operations used in Mechanics.
---
--- ```luau
--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- local std = require(ReplicatedStorage:WaitForChild("KitStd"))
--- ```
local std = {}

--- @prop version string
--- @within KitStd
--- The current version of the Kit Standard Library.
std.version = "1.0.0-dev"

--- @prop activation KitStdActivation
--- @within KitStd
--- Activation utilities.
std.activation = activation

--- @prop animation unknown
--- @within KitStd
--- Animation utilities including tweens.
std.animation = animation

--- @prop assets unknown
--- @within KitStd
--- Image and sound assets used by Welcome To Hell.
std.assets = assets

--- @prop audio unknown
--- @within KitStd
--- Audio utilities.
std.audio = audio

--- @prop bindings KitStdBindings
--- @within KitStd
--- Bindings to Welcome To Hell's controllers.
std.bindings = bindings

--- @prop character unknown
--- @within KitStd
--- Character utilities.
std.character = character

--- @prop collections unknown
--- @within KitStd
--- Collection utilities and implementations.
std.collections = collections

--- @prop color unknown
--- @within KitStd
--- Color utilities.
std.color = color

--- @prop logger unknown
--- @within KitStd
--- Logger implementation.
std.logger = logger

--- @prop collections unknown
--- @within KitStd
--- Math utilities.
std.math = math

std.never = never

--- @prop physics unknown
--- @within KitStd
--- Physic utilities.
std.physics = physics

--- @prop touch unknown
--- @within KitStd
--- Touch utilities.
std.touch = touch

--- @prop prelude KitStdPrelude
--- @within KitStd
--- Reference to the prelude, the list of things that most KitScripts will use,
--- and is kept as small as possible.
std.prelude = prelude
std.packages = table.freeze({
	t = t,
	createTrove = trove.Trove.new,
	sift = sift,
	createLemonSignal = lemonSignal.Signal.new,
})

return table.freeze(std)
