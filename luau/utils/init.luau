--!strict

-- We write the MechanicLib in Luau to enable using Luau type definitions
-- Inspired by http://github.com/znotfireman/jtoh-kit

local Players = game:GetService("Players")

local character = require(script.character)
local checks = require(script.checks)
local geometry = require(script.geometry)
local t = require(script.t)
local types = require(script.types)

export type Mechanic<Attributes, Instance, Methods = {}> = types.Mechanic<Attributes, Instance, Methods>
export type MechanizeContext<MechanicAttributes, MechanicInstance> = types.MechanizeContext<
	MechanicAttributes,
	MechanicInstance
>
export type Character = types.Character
export type TouchConfig = types.TouchConfig
export type Trove = types.Trove
export type TroveTrackable = types.TroveTrackable

local utils = table.freeze({
	getMaybeCharacter = character.getMaybeCharacter,
	waitForCharacter = character.waitForCharacter,
	getCharacter = character.getCharacter,
	getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart,
	getHumanoidRootPart = character.getHumanoidRootPart,
	getMaybeHumanoid = character.getMaybeHumanoid,
	getHumanoid = character.getHumanoid,
	isCharacterAlive = character.isCharacterAlive,

	checkTouched = checks.checkTouched,

	getRandomPointInBox = geometry.getRandomPointInBox,
	getRandomPointInSphere = geometry.getRandomPointInSphere,
	isPointInObject = geometry.isPointInObject,

	localPlayer = Players.LocalPlayer,

	--- Runtime typechecking utilities.
	--- See: https://github.com/osyrisrblx/t
	t = table.freeze(t),
})

return utils
