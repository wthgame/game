--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require("./packages/cull-throttle")
local LemonSignal = require("./packages/lemon-signal")
local Sift = require("./packages/sift")
local activation = require("./activation")
local animation = require("./animation")
local assets = require("./assets")
local attributes = require("./attributes")
local audio = require("./audio")
local bindings = require("./bindings")
local character = require("./character")
local collections = require("./collections")
local color = require("./color")
local physics = require("./physics")
local t = require("./packages/t")
local touch = require("./touch")
local trove = require("./packages/trove")
local types = require("./types")

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
export type Connection<U...> = LemonSignal.Connection<U...>
export type Signal<T...> = LemonSignal.Signal<T...>

--[=[
    @class KitUtils

    In addition to the Welcome To Hell API which is bundled as part of the kit,
    the game also provides this sibling package that contains a set of utilities
    to streamline common patterns and operations used in Mechanics.

    ```Lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
    ```
]=]
local utils = table.freeze({
	--[=[
        @within KitUtils
        @prop version string

		The utils version, pairing with the kit version.
    ]=]
	version = "1.0.0-dev",

	attribute = attributes.attribute,

	connectActivation = activation.connectActivation,
	Active = activation.Active,
	ActivationMode = activation.ActivationMode,
	MaxActivationDistance = activation.MaxActivationDistance,
	ActivationKeyCode = activation.ActivationKeyCode,

	isToucherValid = touch.isToucherValid,
	isToucherCharacter = touch.isToucherCharacter,
	SupportsCharacter = touch.SupportsCharacter,
	SupportsBoxes = touch.SupportsBoxes,
	BoxesRequiresMatchingId = touch.BoxesRequiresMatchingId,
	RequiredBoxId = touch.RequiredBoxId,

	MapSet = collections.MapSet,
	MapArray = collections.MapArray,

	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	isFromMaybeCharacter = character.isFromMaybeCharacter,
	isFromCharacter = character.isFromCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacter = character.isCharacter,
	isLocalPlayerCharacter = character.isLocalPlayerCharacter,
	isCharacterAlive = character.isCharacterAlive,

	tweenInfoFromTweenConfig = animation.tweenInfoFromTweenConfig,
	tweenConfigFromAttributes = animation.tweenConfigFromAttributes,
	tween = animation.tween,
	tweenMaybeInstant = animation.tweenMaybeInstant,

	UI_ASSETS = assets.UI_ASSETS,
	SOUND_ASSETS = assets.SOUND_ASSETS,

	inferAndPlaySound = audio.inferAndPlaySound,
	playSound = audio.playSound,
	playSoundFromGameAssets = audio.playSoundFromGameAssets,

	weld = physics.weld,
	populateConstraintAttachments = physics.populateConstraintAttachments,
	intoCFrameOffset = physics.intoCFrameOffset,

	roundColor = color.roundColor,

	t = t,
	isBasePart = t.instanceIsA("BasePart") :: check<BasePart>,
	isString = t.string,
	isBoolean = t.boolean,
	isPositiveNumber = t.numberPositive,

	Trove = trove.Trove,
	CullThrottle = CullThrottle,
	Sift = Sift,

	isSignal = LemonSignal.Signal.is,
	newSignal = LemonSignal.Signal.new,
	wrapSignal = LemonSignal.Signal.wrap,

	_ = {
		addMechanicBinding = bindings.addMechanicBinding,
		callMechanicBinding = bindings.callMechanicBinding,
	},
})

return utils
