--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local character = require("./character")
local isCharacter = character.isCharacter
local isLocalPlayerCharacter = character.isLocalPlayerCharacter
local types = require("./types")

--- Returns true if a character is touching the part
local function isCharacterTouchingPart(part: BasePart)
	for _, toucher in workspace:GetPartsInPart(part) do
		local character = toucher.Parent
		if character then
			return isCharacter(character)
		end
	end

	return false
end

--- Returns true if the local player's character is touching the part
local function isLocalPlayerCharacterTouchingPart(part: BasePart)
	for _, toucher in workspace:GetPartsInPart(part) do
		local character = toucher.Parent
		if character then
			return isLocalPlayerCharacter(character)
		end
	end

	return false
end

--- Returns true if a part passes the config, which can filter the following:
---
--- * Pass all player characters
--- * Pass only the local player's character
local function isTouched(toucher: BasePart, config: types.TouchConfig): boolean
	local character = toucher.Parent
	if character then
		if config.passAllPlayerCharacters then
			return isCharacter(character)
		elseif config.passLocalPlayerCharacter then
			return isLocalPlayerCharacter(character)
		end
	end

	return false
end

--- Returns true if a part is touched based on the config, which can filter the
--- following:
---
--- * Pass all player characters
--- * Pass only the local player's character
local function isPartTouched(part: BasePart, config: types.TouchConfig): boolean
	for _, toucher in workspace:GetPartsInPart(part) do
		if isTouched(toucher, config) then
			return true
		end
	end

	return false
end

--- Returns all parts touched based on the config, which can filter the
--- following:
---
--- * Pass all player characters
--- * Pass only the local player's character
local function getPartTouched(part: BasePart, config: types.TouchConfig): { [BasePart]: true }
	local touched: { [BasePart]: true } = {}

	for _, toucher in workspace:GetPartsInPart(part) do
		if isTouched(toucher, config) then
			touched[toucher] = true
		end
	end

	return touched
end

return {
	isCharacter = isCharacter,
	isLocalPlayerCharacter = isLocalPlayerCharacter,
	isCharacterTouchingPart = isCharacterTouchingPart,
	isLocalPlayerCharacterTouchingPart = isLocalPlayerCharacterTouchingPart,
	isTouched = isTouched,
	isPartTouched = isPartTouched,
	getPartTouched = getPartTouched,
}
