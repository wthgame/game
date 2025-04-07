--!strict

-- We write the MechanicLib in Luau to enable using Luau type definitions
-- Inspired by http://github.com/znotfireman/jtoh-kit

local character = require(script.character)
local t = require(script.t)
local types = require(script.types)

export type Mechanic<Attributes, Instance> = types.Mechanic<Attributes, Instance>
export type MechanizeContext<MechanicAttributes, MechanicInstance> = types.MechanizeContext<
	MechanicAttributes,
	MechanicInstance
>
export type TouchConfig = types.TouchConfig

local utils = table.freeze({
	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacterAlive = character.isCharacterAlive,

	checkTouched = require(script.checkTouched),

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),
})

return utils
