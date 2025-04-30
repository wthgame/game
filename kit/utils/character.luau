--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")

local types = require("./types")

--- @within KitUtils
--- @tag Character
--- Returns true if a model is a character
local function isCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) ~= nil
end

--- @within KitUtils
--- @tag Character
--- Returns true if a model is the local player's character
local function isLocalPlayerCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) == Players.LocalPlayer
end

--- @within KitUtils
--- @tag Character
--- Returns the local player's character if it exists
local function getMaybeCharacter(): types.Character?
	return Players.LocalPlayer.Character
end

--- @within KitUtils
--- @tag Character
--- Waits for and returns the local player's character when it is added
local function waitForCharacter(): types.Character
	return Players.LocalPlayer.CharacterAdded:Wait()
end

--- @within KitUtils
--- @tag Character
--- Returns current character if it exists. Otherwise, wait for it to be added.
local function getCharacter(): types.Character
	return getMaybeCharacter() or waitForCharacter()
end

--- @within KitUtils
--- @tag Character
--- Returns true if the character exists and the given instance is a descendant
--- of the local character.
local function isFromMaybeCharacter(instance: Instance): boolean
	local character = getMaybeCharacter()
	return if character then character:IsAncestorOf(instance) else false
end

--- @within KitUtils
--- @tag Character
--- Returns true if the given instance is a descendant of the local character.
local function isFromCharacter(instance: Instance): boolean
	return getCharacter():IsAncestorOf(instance)
end

--- @within KitUtils
--- @tag Character
--- Returns the character's HumanoidRootPart if it exists.
local function getMaybeHumanoidRootPart(): BasePart?
	local character = getMaybeCharacter()
	if character then
		return character:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	return nil
end

--- @within KitUtils
--- @tag Character
--- Returns the character's HumanoidRootPart if it exists. Otherwise, wait for
--- it to be added.
local function getHumanoidRootPart(): BasePart
	return getCharacter():WaitForChild("HumanoidRootPart") :: BasePart
end

--- @within KitUtils
--- @tag Character
--- Returns the character's Humanoid if it exists.
local function getMaybeHumanoid(): Humanoid?
	local character = getMaybeCharacter()
	if character then
		return character:FindFirstChild("Humanoid") :: Humanoid
	end
	return nil
end

--- @within KitUtils
--- @tag Character
--- Returns the character's Humanoid if it exists. Otherwise, waits for it to
--- be added.
local function getHumanoid(): Humanoid
	return getCharacter():WaitForChild("Humanoid") :: Humanoid
end

--- @within KitUtils
--- @tag Character
--- Returns true if the character is alive.
local function isCharacterAlive(): boolean
	local humanoid = getMaybeHumanoid()
	return humanoid ~= nil and humanoid.Health > 0
end

-- TODO: getMaybeAnimator, getAnimator
-- This will probably come after we implement custom animations

return {
	isCharacter = isCharacter,
	isLocalPlayerCharacter = isLocalPlayerCharacter,
	getMaybeCharacter = getMaybeCharacter,
	waitForCharacter = waitForCharacter,
	getCharacter = getCharacter,
	isFromMaybeCharacter = isFromMaybeCharacter,
	isFromCharacter = isFromCharacter,
	getMaybeHumanoidRootPart = getMaybeHumanoidRootPart,
	getHumanoidRootPart = getHumanoidRootPart,
	getMaybeHumanoid = getMaybeHumanoid,
	getHumanoid = getHumanoid,
	isCharacterAlive = isCharacterAlive,
}
