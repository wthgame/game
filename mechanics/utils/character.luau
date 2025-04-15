--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")

local types = require("./types")

--- Returns true if a model is a character
local function isCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) ~= nil
end

--- Returns true if a model is the local player's character
local function isLocalPlayerCharacter(character: Instance): boolean
	return Players:GetPlayerFromCharacter(character :: Model) == Players.LocalPlayer
end

--- Returns the local player's character if it exists
local function getMaybeCharacter(): types.Character?
	return Players.LocalPlayer.Character
end

--- Waits for and returns the local player's character when it is added
local function waitForCharacter(): types.Character
	return Players.LocalPlayer.CharacterAdded:Wait()
end

--- Returns current character if it exists. Otherwise, wait for it to be added.
local function getCharacter(): types.Character
	return getMaybeCharacter() or waitForCharacter()
end

local function getMaybeHumanoidRootPart(): BasePart?
	local character = getMaybeCharacter()
	if character then
		return character:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	return nil
end

local function getHumanoidRootPart(): BasePart
	return getCharacter():WaitForChild("HumanoidRootPart") :: BasePart
end

local function getMaybeHumanoid(): Humanoid?
	local character = getMaybeCharacter()
	if character then
		return character:FindFirstChild("Humanoid") :: Humanoid
	end
	return nil
end

local function getHumanoid(): Humanoid
	return getCharacter():WaitForChild("Humanoid") :: Humanoid
end

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
	getMaybeHumanoidRootPart = getMaybeHumanoidRootPart,
	getHumanoidRootPart = getHumanoidRootPart,
	getMaybeHumanoid = getMaybeHumanoid,
	getHumanoid = getHumanoid,
	isCharacterAlive = isCharacterAlive,
}
