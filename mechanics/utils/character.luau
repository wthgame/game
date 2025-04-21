--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")

local types = require("./types")

--- @within MechanicUtils
--- @tag Character
--- Returns true if a model is a character
local function isCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) ~= nil
end

--- @within MechanicUtils
--- @tag Character
--- Returns true if a model is the local player's character
local function isLocalPlayerCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) == Players.LocalPlayer
end

--- @within MechanicUtils
--- @tag Character
--- Returns the local player's character if it exists
local function getMaybeLocalCharacter(): types.Character?
	return Players.LocalPlayer.Character
end

--- @within MechanicUtils
--- @tag Character
--- Waits for and returns the local player's character when it is added
local function waitForLocalCharacter(): types.Character
	return Players.LocalPlayer.CharacterAdded:Wait()
end

--- @within MechanicUtils
--- @tag Character
--- Returns current character if it exists. Otherwise, wait for it to be added.
local function getLocalCharacter(): types.Character
	return getMaybeLocalCharacter() or waitForLocalCharacter()
end

--- @within MechanicUtils
--- @tag Character
--- Returns true if the character exists and the given instance is a descendant
--- of the local character.
local function isFromMaybeLocalCharacter(instance: Instance): boolean
	local character = getMaybeLocalCharacter()
	return if character then character:IsAncestorOf(instance) else false
end

--- @within MechanicUtils
--- @tag Character
--- Returns true if the given instance is a descendant of the local character.
local function isFromLocalCharacter(instance: Instance): boolean
	return getLocalCharacter():IsAncestorOf(instance)
end

--- @within MechanicUtils
--- @tag Character
--- Returns the character's HumanoidRootPart if it exists.
local function getMaybeLocalHumanoidRootPart(): BasePart?
	local character = getMaybeLocalCharacter()
	if character then
		return character:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	return nil
end

--- @within MechanicUtils
--- @tag Character
--- Returns the character's HumanoidRootPart if it exists. Otherwise, wait for
--- it to be added.
local function getLocalHumanoidRootPart(): BasePart
	return getLocalCharacter():WaitForChild("HumanoidRootPart") :: BasePart
end

--- @within MechanicUtils
--- @tag Character
--- Returns the character's Humanoid if it exists.
local function getMaybeLocalHumanoid(): Humanoid?
	local character = getMaybeLocalCharacter()
	if character then
		return character:FindFirstChild("Humanoid") :: Humanoid
	end
	return nil
end

--- @within MechanicUtils
--- @tag Character
--- Returns the character's Humanoid if it exists. Otherwise, waits for it to
--- be added.
local function getLocalHumanoid(): Humanoid
	return getLocalCharacter():WaitForChild("Humanoid") :: Humanoid
end

--- @within MechanicUtils
--- @tag Character
--- Returns true if the character is alive.
local function isLocalCharacterAlive(): boolean
	local humanoid = getMaybeLocalHumanoid()
	return humanoid ~= nil and humanoid.Health > 0
end

-- TODO: getMaybeAnimator, getAnimator
-- This will probably come after we implement custom animations

return {
	isCharacter = isCharacter,
	isLocalPlayerCharacter = isLocalPlayerCharacter,
	getMaybeLocalCharacter = getMaybeLocalCharacter,
	waitForLocalCharacter = waitForLocalCharacter,
	getLocalCharacter = getLocalCharacter,
	isFromMaybeLocalCharacter = isFromMaybeLocalCharacter,
	isFromLocalCharacter = isFromLocalCharacter,
	getMaybeLocalHumanoidRootPart = getMaybeLocalHumanoidRootPart,
	getLocalHumanoidRootPart = getLocalHumanoidRootPart,
	getMaybeLocalHumanoid = getMaybeLocalHumanoid,
	getLocalHumanoid = getLocalHumanoid,
	isLocalCharacterAlive = isLocalCharacterAlive,
}
