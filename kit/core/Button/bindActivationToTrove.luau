--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonAttributes = require("./ButtonAttributes")
type ActivatedBy = ButtonAttributes.ActivatedBy
local ActivatedBy = ButtonAttributes.ActivatedBy
local MaxActivationDistance = ButtonAttributes.MaxActivationDistance
local createDefaultClickDetector = require("./createDefaultClickDetector")
local createDefaultPrompt = require("./createDefaultPrompt")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local function bindActivationToTrove(trove: utils.Trove, btn: BasePart, onActivated: () -> ())
	local activatedBy = ActivatedBy(btn)
	if activatedBy == "Touch" then
		trove:connect(btn.Touched, function(toucher)
			if utils.isToucher(btn, toucher) then
				onActivated()
			end
		end)
	elseif activatedBy == "Prompt" then
		local buttonPrompt = btn:FindFirstChild("ButtonProximityPrompt", true) :: ProximityPrompt

		if not buttonPrompt then
			buttonPrompt = createDefaultPrompt(trove, btn)
		elseif buttonPrompt.ClassName ~= "ProximityPrompt" then
			-- someones trying to troll the game
			buttonPrompt.Name ..= "_OLD"
			buttonPrompt = createDefaultPrompt(trove, btn)
		end

		buttonPrompt.MaxActivationDistance = MaxActivationDistance(btn)

		trove:connect(buttonPrompt.Triggered, function(player: Player)
			-- TODO: do we need this?
			if player == Players.LocalPlayer then
				onActivated()
			end
		end)
	elseif activatedBy == "Click" then
		local buttonClick = btn:FindFirstChild("ButtonClickDetector", true) :: ClickDetector

		if not buttonClick then
			buttonClick = createDefaultClickDetector(trove, btn)
		elseif buttonClick.ClassName ~= "ClickDetector" then
			-- someones trying to troll the game
			buttonClick.Name ..= "_OLD"
			buttonClick = createDefaultClickDetector(trove, btn)
		end

		buttonClick.MaxActivationDistance = MaxActivationDistance(btn)

		trove:connect(buttonClick.MouseClick, function(player: Player)
			-- TODO: do we need this?
			if player == Players.LocalPlayer then
				onActivated()
			end
		end)
	elseif activatedBy == "Control" then
	else
		error("Invalid ActivatedBy (unreachable?)")
	end

	return trove
end

return bindActivationToTrove
