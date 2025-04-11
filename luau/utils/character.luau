--!strict

local Players = game:GetService("Players")

local Types = require(script.Parent.Types)

local Character = {}

function Character.getMaybeCharacter(): Types.Character?
	return Players.LocalPlayer.Character
end

function Character.waitForCharacter(): Types.Character
	return Players.LocalPlayer.CharacterAdded:Wait()
end

function Character.getCharacter(): Types.Character
	return Character.getMaybeCharacter() or Character.waitForCharacter()
end

function Character.getMaybeHumanoidRootPart(): BasePart?
	local character = Character.getMaybeCharacter()
	if character then
		return character:FindFirstChild("HumanoidRootPart") :: BasePart
	end
	return nil
end

function Character.getHumanoidRootPart(): BasePart
	return Character.getCharacter():WaitForChild("HumanoidRootPart") :: BasePart
end

function Character.getMaybeHumanoid(): Humanoid?
	local character = Character.getMaybeCharacter()
	if character then
		return character:FindFirstChild("Humanoid") :: Humanoid
	end
	return nil
end

function Character.getHumanoid(): Humanoid
	return Character.getCharacter():WaitForChild("Humanoid") :: Humanoid
end

function Character.isCharacterAlive(): boolean
	local humanoid = Character.getMaybeHumanoid()
	return humanoid ~= nil and humanoid.Health > 0
end

-- TODO: getMaybeAnimator, getAnimator
-- This will probably come after we implement custom animations

table.freeze(Character)
return Character
