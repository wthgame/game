local utils = require(script.lib)

export type Map<K, V> = utils.Map<K, V>
export type KitContext = utils.KitContext
export type Mechanic<Instance, Attributes> = utils.Mechanic<Instance, Attributes>
export type MechanicContext<Instance, Attributes> = utils.MechanicContext<Instance, Attributes>
export type WTH = utils.WTH

return utils
