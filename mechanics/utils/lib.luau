local CullThrottle = require("./packages/cull-throttle")
local character = require("./character")
local t = require("./packages/t")
local trove = require("./packages/trove")
local types = require("./types")

export type Map<K, V> = types.Map<K, V>
export type KitContext = types.KitContext
export type Mechanic<Instance, Attributes> = types.Mechanic<Instance, Attributes>
export type MechanicContext<Instance, Attributes> = types.MechanicContext<Instance, Attributes>
export type WTH = types.WTH

local utils = table.freeze({
	version = "1.0.0-dev",

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

	t = t,
	Trove = trove.Trove,
	CullThrottle = CullThrottle,
})

return utils
