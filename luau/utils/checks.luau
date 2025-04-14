--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")

local types = require("./types")

local function isCharacter(character: Model): boolean
	return Players:GetPlayerFromCharacter(character :: Model) ~= nil
end

local function isLocalPlayerCharacter(character: Model): boolean
	return Players:GetPlayerFromCharacter(character :: Model) == Players.LocalPlayer
end

local function isCharacterTouchingPart(part: BasePart)
	for _, toucher in workspace:GetPartsInPart(part) do
		local character = toucher.Parent
		if character then
			return isCharacter(character)
		end
	end

	return false
end

local function isLocalPlayerCharacterTouchingPart(part: BasePart)
	for _, toucher in workspace:GetPartsInPart(part) do
		local character = toucher.Parent
		if character then
			return isLocalPlayerCharacter(character)
		end
	end

	return false
end

--- Returns true if a touching part passes the config, which can filter the
--- following:
---
--- * Pass all player characters
--- * Pass only the local player's character
local function isTouched(toucher: BasePart, config: types.TouchConfig): boolean
	local character = toucher.Parent :: Model
	if character then
		if config.passAllPlayerCharacters then
			return isCharacter(character)
		elseif config.passLocalPlayerCharacters then
			return isLocalPlayerCharacter(character)
		end
	end

	return false
end

--- Returns true if a toucher part passes the config, which can filter the
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

return {
	isCharacter = isCharacter,
	isLocalPlayerCharacter = isLocalPlayerCharacter,
	isLocalPlayerCharacterTouchingPart = isLocalPlayerCharacterTouchingPart,
	isTouched = isTouched,
	isPartTouched = isPartTouched,
}
