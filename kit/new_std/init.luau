--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local activation = require(script.activation)
local attributes = require(script.attributes)
local lemonSignal = require(script.packages.lemonSignal)
local logger = require(script.logger)
local prelude = require(script.prelude)
local sift = require(script.packages.sift)
local t = require(script.packages.t)
local tags = require(script.tags)
local trove = require(script.packages.trove)
local types = require(script.types)

export type Map<K, V> = types.Map<K, V>
export type Set<T> = types.Set<T>
export type Tag<T> = tags.Tag<T>
export type Attribute<T> = attributes.Attribute<T>

export type check<T> = t.check<T>
export type Trove = trove.Trove
export type LemonConnection<U...> = lemonSignal.Connection<U...>
export type LemonSignal<T...> = lemonSignal.Signal<T...>

--- @class KitStd
--- @since 1.0.0
---
--- The Welcome To Hell Kit Standard Library is contains many utilities,
--- including types like InstanceAttribute,
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

--- @prop logger unknown
--- @within KitStd
--- Logger implementation.
std.logger = logger

--- @prop collections unknown
--- @within KitStd
--- Math utilities.
std.math = math

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
