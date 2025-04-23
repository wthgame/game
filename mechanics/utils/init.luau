--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local utils = require(script.lib)

export type Map<K, V> = utils.Map<K, V>
export type Set<T> = utils.Set<T>
export type InstanceTag<I> = utils.InstanceTag<I>
export type WTH = utils.WTH
export type Character = utils.Character
export type PlaySoundConfig = utils.PlaySoundConfig
export type TweenConfig = utils.TweenConfig

export type check<T> = utils.check<T>
export type Trove = utils.Trove

return utils
