--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: this is a very rough implementation

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

-- TODO: control
type ActivatedBy = "Touch" | "Prompt" | "Click"

local DEFAULT_ACTIVE_TRANSPARENCY = 0
local DEFAULT_INACTIVE_TRANSPARENCY = 0.6

local ButtonId = utils.attribute("ButtonId", utils.t.string)
local ButtonPressed = utils.attribute("ButtonPressed", utils.t.boolean, false)
local ActivatedBy = utils.attribute("ActivatedBy", utils.t.literal("Touch", "Prompt", "Click"), "Touch")
local HoldDuration = utils.attribute("HoldDuration", utils.t.numberPositive, 0)
local MaxActivationDistance = utils.attribute("MaxActivationDistance", utils.t.numberPositive, math.huge)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
local Duration = utils.attribute("Duration", utils.t.numberPositive, 0)
local SupportsCharacter = utils.attribute("SupportsCharacter", utils.t.boolean, true)

local Invert = utils.attribute("Invert", utils.t.boolean, false)

local function createDefaultPrompt(trove: utils.Trove, btn: BasePart)
	local promptAttachment = trove:add(Instance.new("Attachment"))
	promptAttachment.Name = "ButtonPromptAttachment"

	local prompt = trove:add(Instance.new("ProximityPrompt"))
	prompt.Name = "ButtonProximityPrompt"
	prompt.ActionText = "Activate"
	prompt.RequiresLineOfSight = false

	prompt.Parent = btn
	promptAttachment.Parent = btn

	return prompt
end

local function createDefaultClickDetector(trove: utils.Trove, btn: BasePart)
	local clickDetector = trove:add(Instance.new("ClickDetector"))
	clickDetector.Name = "ButtonClickDetector"
	clickDetector.Parent = btn

	return clickDetector
end

local function toggleVisibilityAndCollision(instance: BasePart, active: boolean)
	local nextState = if active then "Active" else "Inactive"
	local currentState = if active then "Inactive" else "Active"
	local defaultTransparency = if active then DEFAULT_ACTIVE_TRANSPARENCY else DEFAULT_INACTIVE_TRANSPARENCY

	if not instance:GetAttribute(`{currentState}Transparency`) then
		instance:SetAttribute(`{currentState}Transparency`, instance.Transparency)
	end

	if not instance:GetAttribute(`{nextState}Transparency`) then
		instance:SetAttribute(`{nextState}Transparency`, defaultTransparency)
	end

	if not instance:GetAttribute("KeepCollision") then
		instance.CanCollide = not instance.CanCollide
	end

	instance.Transparency = instance:GetAttribute(`{nextState}Transparency`) :: any
	-- local tweenInfo = tweenInfo()

	-- local tweenParameters = {}
	-- tweenParameters.Transparency = transparency

	-- TweenService:Create(instance, tweenInfo, tweenParameters):Play()
	-- for _, descendant in instance:GetDescendants() do
	-- 	updateGraphics(descendant, transparency, active, tweenInfo)
	-- end
end

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
				toggleVisibilityAndCollision(ba, active)
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

		task.delay(Duration(btn), function()
			btn:SetAttribute("ButtonPressed", false)
		end)
	end

	local function bindActivation(outerTrove: utils.Trove, btn: BasePart, activatedBy: ActivatedBy)
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
	end)
end

return new
