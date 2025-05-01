local MapSet = require(script.mapset)

export type MapSet<K, T> = MapSet.MapSet<K, T>

return {
	MapSet = MapSet,
}
