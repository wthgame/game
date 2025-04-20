--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require("./packages/cull-throttle")
local assets = require("./assets")
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
export type KitContext = types.KitContext
export type Mechanic<Instance, Attributes> = types.Mechanic<Instance, Attributes>
export type MechanicContext<Instance, Attributes> = types.MechanicContext<Instance, Attributes>
export type WTH = types.WTH

local utils = table.freeze({
	version = "1.0.0-dev",

	ASSETS = assets,

	SOUND_ASSETS = audio.SOUND_ASSETS,
	playSound = audio.playSound,
	playSoundFromGameAssets = audio.playSoundFromGameAssets,

	promptToStartNewTowerRun = bindings.promptToStartNewTowerRun,

	roundColor = color.roundColor,

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
