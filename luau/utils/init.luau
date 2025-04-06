-- We write the MechanicLib in Luau to enable using Luau type definitions
-- Inspired by http://github.com/znotfireman/jtoh-kit

local t = require(script.t)
local types = require(script.types)

export type Mechanic<Config> = types.Mechanic<Config>

local MechanicUtils = table.freeze({
	t = table.freeze(t),

	mechanic = function<C>(x: Mechanic<C>)
		return table.freeze(x)
	end,
})

return MechanicUtils
