--!strict
local Players = game:GetService("Players")

local types = require(script.Parent.types)

local character = {}

function character.getMaybeCharacter(): types.Character?
	return Players.LocalPlayer.Character
end

function character.waitForCharacter(): types.Character
	return Players.LocalPlayer.CharacterAdded:Wait()
end

function character.getCharacter(): types.Character
	return character.getMaybeCharacter() or character.waitForCharacter()
end

function character.getMaybeHumanoidRootPart(): BasePart?
	local character = character.getMaybeCharacter()
	if character then
		return character:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	return nil
end

function character.getHumanoidRootPart(): BasePart
	return character.getCharacter():WaitForChild("HumanoidRootPart") :: BasePart
end

function character.getMaybeHumanoid(): Humanoid?
	local character = character.getMaybeCharacter()
	if character then
		return character:FindFirstChild("Humanoid") :: Humanoid
	end
	return nil
end

function character.getHumanoid(): Humanoid
	return character.getCharacter():WaitForChild("Humanoid") :: Humanoid
end

function character.isCharacterAlive(): boolean
	local humanoid = character.getMaybeHumanoid()
	return humanoid ~= nil and humanoid.Health > 0
end

-- TODO: getMaybeAnimator, getAnimator
-- This will probably come after we implement custom animations

table.freeze(character)
return character
