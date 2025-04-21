--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local utils = require(script.lib)

export type Map<K, V> = utils.Map<K, V>
export type Set<T> = utils.Set<T>
export type KitContext = utils.KitContext
export type Mechanic<Instance, Attributes> = utils.Mechanic<Instance, Attributes>
export type MechanicContext<Instance, Attributes> = utils.MechanicContext<Instance, Attributes>
export type PlaySoundConfig = utils.PlaySoundConfig
export type WTH = utils.WTH

export type Trove = utils.Trove

return utils
