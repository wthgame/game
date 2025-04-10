local t = require(script.t)
local types = require(script.types)

export type Mechanic = types.Mechanic
export type MechanicComponent<Attributes, Instance> = types.MechanicComponent<Attributes, Instance>

return {
	Mechanic = function(x: Mechanic)
		return x
	end,

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),
}
