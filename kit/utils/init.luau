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
local sift = require(script.packages.sift)
local t = require(script.packages.t)
local touch = require(script.touch)
local trove = require(script.packages.trove)
local types = require(script.types)

export type Map<K, V> = types.Map<K, V>
export type Set<T> = types.Set<T>
export type MapSet<K, T> = collections.MapSet<K, T>
export type MapArray<K, T> = collections.MapArray<K, T>
export type Kit = types.Kit
export type KitScript<Self = {}> = types.KitScript<Self>
export type InstanceTag<I> = types.InstanceTag<I>
export type InstanceByIds<Instance, Id> = types.InstanceByIds<Instance, Id>
export type InstanceAttribute<T> = attributes.InstanceAttribute<T>
export type ActivationMode = activation.ActivationMode
export type Character = types.Character
export type PlaySoundConfig = audio.PlaySoundConfig
export type TweenConfig = animation.TweenConfig

export type check<T> = t.check<T>
export type Trove = trove.Trove
export type LemonConnection<U...> = lemonSignal.Connection<U...>
export type LemonSignal<T...> = lemonSignal.Signal<T...>

--- In addition to the Welcome To Hell API which is bundled as part of the kit,
--- the game also provides this sibling package that contains a set of utilities
--- to streamline common patterns and operations used in Mechanics.
---
--- ```luau
--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
--- ```
local utils = table.freeze({
	version = "1.0.0-dev",

	animation = animation,
	assets = assets,
	audio = audio,
	bindings = bindings,
	character = character,
	collections = collections,
	color = color,
	math = math,
	never = never,
	physics = physics,
	touch = touch,

	prelude = table.freeze(
		--- Welcome To Hell comes with a variety of things in its utility
		--- library. However, if you had to manually import every single thing
		--- that you used, it would be very verbose. But importing a lot of
		--- things that a script never uses isn’t good either. A balance needs
		--- to be struck.
		---
		--- The prelude is the list of things that most KitScripts will use, and
		--- is kept as small as possible.
		---
		--- ```luau
		--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
		--- local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
		--- local prelude = utils.prelude
		--- ```
		---
		--- When Luau table destructuring is implemented, the prelude can be
		--- imported as such:
		---
		--- ```luau
		--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
		--- local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
		--- -- waiting on https://github.com/luau-lang/rfcs/pull/95
		--- local { .attribute, .isBasePart, .getMaybeRootPart } = utils.prelude
		--- ```
		{
			createLogger = logger.createLogger,

			attribute = attributes.attribute,

			Active = activation.Active,
			connectActivation = activation.connectActivation,

			getHumanoid = character.getHumanoid,
			getMaybeHumanoid = character.getMaybeHumanoid,
			getHumanoidRootPart = character.getHumanoidRootPart,
			getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,

			t = t,
			isBasePart = t.instanceIsA("BasePart") :: t.check<BasePart>,
			isPositiveNumber = t.numberMin(0),
			isBoolean = t.boolean,
			isString = t.string,

			tweenConfigFromAttributes = animation.tweenConfigFromAttributes,
			tween = animation.tween,
			tweenMaybeInstant = animation.tweenMaybeInstant,

			IMAGE_ASSETS = assets.IMAGE_ASSETS,
			AUDIO_ASSETS = audio.AUDIO_ASSETS,
			inferAndPlaySound = audio.inferAndPlaySound,
			playSound = audio.playSound,
			playSoundFromGameAssets = audio.playSoundFromGameAssets,
		}
	),
	packages = table.freeze(
		--- References to common packages.
		{
			t = t,
			createTrove = trove.Trove.new,
			sift = sift,
			createLemonSignal = lemonSignal.Signal.new,
		}
	),
})

do
	-- HOW IS THIS PACKAGE NOT PROPERLY TYPED...
	-- TODO: TYPE THIS SHIT
	(sift.Dictionary.freezeDeep :: any)(utils)
end

return utils
