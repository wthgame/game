-- We write the MechanicLib in Luau to enable using Luau type definitions
-- Inspired by http://github.com/znotfireman/jtoh-kit

local t = require(script.t)
local types = require(script.types)

export type MechanicDescription<Attributes, Instance> = types.MechanicDescription<Attributes, Instance>
export type MechanizeScope<MechanicAttributes, MechanicInstance> = types.MechanizeScope<
	MechanicAttributes,
	MechanicInstance
>
export type TouchConfig = types.TouchConfig

local utils = table.freeze({
	checkTouched = require(script.checkTouched),

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),
})

return utils
