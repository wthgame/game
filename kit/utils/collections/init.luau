local MapArray = require(script.maparray)
local MapSet = require(script.mapset)

export type MapSet<K, T> = MapSet.MapSet<K, T>
export type MapArray<K, T> = MapArray.MapArray<K, T>

return {
	MapSet = MapSet,
	MapArray = MapArray,
}
