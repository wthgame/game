local t = require(script.t)
local types = require(script.types)

export type Mechanic = types.Mechanic
export type MechanicComponent<Attributes, Instance> = types.MechanicComponent<Attributes, Instance>

return {
	createMechanic = function(name: string, attach: (wth: types.WelcomeToHell) -> ()): Mechanic
		return table.freeze({
			type = "Mechanic" :: "Mechanic",
			name = name,
			attach = attach,
		})
	end,

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),
}
