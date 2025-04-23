--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: this is a very rough implementation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local ButtonActivatedAttributes = require(script:WaitForChild("ButtonActivatedAttributes"))
local Invert = ButtonActivatedAttributes.Invert
local ButtonAttributes = require(script:WaitForChild("ButtonAttributes"))
local ButtonId = ButtonAttributes.ButtonId
local ButtonPressed = ButtonAttributes.ButtonPressed
local ActivatedBy = ButtonAttributes.ActivatedBy
local MaxActivationDistance = ButtonAttributes.MaxActivationDistance
local Duration = ButtonAttributes.Duration
local SupportsCharacter = ButtonAttributes.SupportsCharacter
local PressOffset = ButtonAttributes.PressOffset
local createDefaultClickDetector = require(script:WaitForChild("createDefaultClickDetector"))
local createDefaultPrompt = require(script:WaitForChild("createDefaultPrompt"))
local updateButtonActivatedPart = require(script:WaitForChild("updateButtonActivatedPart"))

local BUTTON_PRESS_TWEEN: utils.TweenConfig = {
	time = 0.25,
	easingStyle = Enum.EasingStyle.Quad,
	easingDirection = Enum.EasingDirection.Out,
}

local function new(wth: utils.WTH)
	local Button = wth:tag("Button", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)
	local ButtonActivated = wth:tag("ButtonActivated")

	-- baby i'd
	local buttonActivatedsById: utils.Map<string, utils.Set<Instance>> = {}

	local function trackButtonActivatedById(id: string, buttonActivated: Instance)
		local existing = buttonActivatedsById[id]
		if existing then
			existing[buttonActivated] = true
		else
			buttonActivatedsById[id] = { [buttonActivated] = true }
		end
	end

	ButtonActivated:onLoaded(function(trove, ba)
		local id = ButtonId(ba)
		if id then
			trackButtonActivatedById(id, ba)
		end

		trove:connect(ba:GetAttributeChangedSignal("ButtonId"), function()
			local id = ButtonId(ba)
			if id then
				trackButtonActivatedById(id, ba)
				-- else
				-- 	local existing = buttonActivatedsById[ba.Name]
				-- 	if existing then
				-- 		existing[ba] = nil
				-- 	end
			end
		end)
	end)

	local buttonsPressedById: utils.Map<string, utils.Set<BasePart>> = {}
	local function trackButtonPressedById(id: string, button: BasePart)
		local existing = buttonsPressedById[id]
		if existing then
			existing[button] = true
		else
			buttonsPressedById[id] = { [button] = true }
		end
	end

	local function untrackButtonPressedById(id: string, button: BasePart)
		local existing = buttonsPressedById[id]
		if existing then
			existing[button] = nil
		end
	end

	local function getButtonPressedById(id: string): utils.Set<BasePart>
		return buttonsPressedById[id] or {}
	end

	local function updateId(id: string)
		local buttonActivateds = buttonActivatedsById[id]
		if not buttonActivateds then
			return
		end

		local isPressed = next(getButtonPressedById(id)) ~= nil

		for ba in buttonActivateds do
			if ba:IsA("BasePart") then
				local active = isPressed
				if Invert(ba) then
					active = not active
				end
				updateButtonActivatedPart(ba, active)
			end
		end
	end

	local function activate(trove: utils.Trove, btn: BasePart)
		local id = ButtonId(btn)

		if ButtonPressed(btn) or not id then
			return
		end

		utils.playSound(utils.SOUND_ASSETS.button)

		btn:SetAttribute("ButtonPressed", true)
		trackButtonPressedById(id, btn)

		btn.Material = Enum.Material.Neon

		local originalCFrame = btn.CFrame
		local pressOffset = PressOffset(btn)
		local finalPressOffset = CFrame.new(Vector3.yAxis * -0.75)
		if typeof(pressOffset) == "number" then
			finalPressOffset = CFrame.new(Vector3.yAxis * -pressOffset)
		elseif typeof(pressOffset) == "Vector3" then
			finalPressOffset = CFrame.new(pressOffset)
		elseif typeof(pressOffset) == "CFrame" then
			finalPressOffset = pressOffset
		end

		if btn.Anchored then
			utils.tween(btn, { CFrame = originalCFrame * finalPressOffset }, BUTTON_PRESS_TWEEN)
		end

		task.delay(Duration(btn), function()
			btn:SetAttribute("ButtonPressed", false)
			if btn.Anchored then
				utils.tween(btn, { CFrame = originalCFrame }, BUTTON_PRESS_TWEEN)
			end
		end)
	end

	local function bindActivation(outerTrove: utils.Trove, btn: BasePart, activatedBy: ButtonAttributes.ActivatedBy)
		local trove = outerTrove:extend()

		if activatedBy == "Touch" then
			trove:connect(btn.Touched, function(toucher)
				local isCharacterTouching = SupportsCharacter(btn) and utils.isFromMaybeLocalCharacter(toucher)
				if isCharacterTouching then
					activate(outerTrove, btn)
					-- trove:clean()
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
					activate(outerTrove, btn)
					-- trove:clean()
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
					activate(outerTrove, btn)
					-- trove:clean()
				end
			end)
		end

		return trove
	end

	local function tryUpdateIdOfButton(btn: Instance)
		local id = ButtonId(btn)
		if id then
			updateId(id)
		end
	end

	Button:onLoaded(function(trove, btn)
		local activationTrove = bindActivation(trove, btn, ActivatedBy(btn))

		trove:connect(btn:GetAttributeChangedSignal("ActivatedBy"), function()
			activationTrove:clean()
			activationTrove = bindActivation(trove, btn, ActivatedBy(btn))
		end)

		local originalMaterial = btn.Material
		trove:connect(btn:GetAttributeChangedSignal("ButtonPressed"), function()
			local id = ButtonId(btn)

			activationTrove:clean()
			if not ButtonPressed(btn) then
				activationTrove = bindActivation(trove, btn, ActivatedBy(btn))
				if id then
					untrackButtonPressedById(id, btn)
				end
				btn.Material = originalMaterial
			end

			if id then
				updateId(id)
			end
		end)

		-- Update once to set initial visibilities
		tryUpdateIdOfButton(btn)

		trove:connect(btn:GetAttributeChangedSignal("ButtonId"), function()
			-- TOOD
		end)
	end)
end

return new
