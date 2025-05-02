--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local utils = require(script.lib)

export type Map<K, V> = utils.Map<K, V>
export type Set<T> = utils.Set<T>
export type MapSet<K, T> = utils.MapSet<K, T>
export type MapArray<K, T> = utils.MapArray<K, T>
export type Kit = utils.Kit
export type KitScript<Self = {}> = utils.KitScript<Self>
export type InstanceTag<I> = utils.InstanceTag<I>
export type InstanceByIds<Instance, Id> = utils.InstanceByIds<Instance, Id>
export type InstanceAttribute<T> = utils.InstanceAttribute<T>
export type ActivationMode = utils.ActivationMode
export type Character = utils.Character
export type PlaySoundConfig = utils.PlaySoundConfig
export type TweenConfig = utils.TweenConfig

export type check<T> = utils.check<T>
export type Trove = utils.Trove
export type Connection<U...> = utils.Connection<U...>
export type Signal<T...> = utils.Signal<T...>

return utils
