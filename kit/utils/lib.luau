--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require("./packages/cull-throttle")
local animation = require("./animation")
local assets = require("./assets")
local attributes = require("./attributes")
local audio = require("./audio")
local bindings = require("./bindings")
local character = require("./character")
local color = require("./color")
local physics = require("./physics")
local t = require("./packages/t")
local trove = require("./packages/trove")
local types = require("./types")

export type Map<K, V> = types.Map<K, V>
export type Set<T> = types.Set<T>
export type Kit = types.Kit
export type KitScript<Self = {}> = types.KitScript<Self>
export type InstanceTag<I> = types.InstanceTag<I>
export type Character = types.Character
export type PlaySoundConfig = types.PlaySoundConfig
export type TweenConfig = types.TweenConfig

export type check<T> = t.check<T>
export type Trove = trove.Trove

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
        @prop version string
	    @within KitUtils

		The utils version, pairing with the kit version.
    ]=]
	version = "1.0.0-dev",

	attribute = attributes.attribute,
	isActive = attributes.isActive,
	getEnumFromString = attributes.getEnumFromString,

	getMaybeLocalCharacter = character.getMaybeLocalCharacter,
	waitForLocalCharacter = character.waitForLocalCharacter,
	getLocalCharacter = character.getLocalCharacter,
	isFromMaybeLocalCharacter = character.isFromMaybeLocalCharacter,
	isFromLocalCharacter = character.isFromLocalCharacter,
	getMaybeLocalHumanoidRootPart = character.getMaybeLocalHumanoidRootPart,
	getLocalHumanoidRootPart = character.getLocalHumanoidRootPart,
	getMaybeLocalHumanoid = character.getMaybeLocalHumanoid,
	getLocalHumanoid = character.getLocalHumanoid,
	isCharacter = character.isCharacter,
	isLocalPlayerCharacter = character.isLocalPlayerCharacter,
	isLocalCharacterAlive = character.isLocalCharacterAlive,

	tween = animation.tween,

	--[=[
        @prop ASSETS typeof(assets)
	    @within KitUtils

		Image and sound assets used by Welcome To Hell.
    ]=]
	ASSETS = assets,

	SOUND_ASSETS = audio.SOUND_ASSETS,
	playSound = audio.playSound,
	playSoundFromGameAssets = audio.playSoundFromGameAssets,

	roundColor = color.roundColor,

	weld = physics.weld,
	populateConstraintAttachments = physics.populateConstraintAttachments,

	t = t,
	Trove = trove.Trove,
	CullThrottle = CullThrottle,

	_ = {
		addMechanicBinding = bindings.addMechanicBinding,
		callMechanicBinding = bindings.callMechanicBinding,
	},
})

return utils
