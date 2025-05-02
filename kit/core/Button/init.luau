--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: button timers and tick sounds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local ButtonActivatedAttributes = require(script:WaitForChild("ButtonActivatedAttributes"))
local ButtonAttributes = require(script:WaitForChild("ButtonAttributes"))
export type ActivatedBy = ButtonAttributes.ActivatedBy
local ButtonId = ButtonAttributes.ButtonId
local ButtonPressed = ButtonAttributes.ButtonPressed
local Duration = ButtonAttributes.Duration
local PlaySound = ButtonAttributes.PlaySound
local PressOffset = ButtonAttributes.PressOffset
local glowButton = require(script:WaitForChild("glowButton"))
local updateButtonActivated = require(script:WaitForChild("updateButtonActivated"))

local idToButtonActivateds: utils.MapSet<string, Instance> = utils.MapSet()
local idToButtonsPressed: utils.MapSet<string, BasePart> = utils.MapSet()

local function updateId(id: string)
	local buttonActivateds = idToButtonActivateds:get(id)
	if not buttonActivateds then
		return
	end

	local isPressed = next(idToButtonsPressed:get(id)) ~= nil

	for ba in buttonActivateds do
		-- updateButtonActivated(ba, isPressed)
		task.spawn(updateButtonActivated, ba, isPressed)
	end
end

local function pressButton(trove: utils.Trove, btn: BasePart, activationTrove: utils.Trove)
	local id = ButtonId(btn)

	if ButtonPressed(btn) or not id then
		return
	end

	activationTrove:clean()

	btn:SetAttribute("ButtonPressed", true)
	idToButtonsPressed:add(id, btn)

	if PlaySound(btn) then
		utils.inferAndPlaySound(btn, utils.SOUND_ASSETS.button, "Press")
	end

	local originalCFrame = btn.CFrame
	local pressOffset = utils.intoCFrameOffset(PressOffset(btn))

	if btn.Anchored then
		utils.tweenMaybeInstant(
			btn,
			{ CFrame = originalCFrame * pressOffset },
			utils.tweenConfigFromAttributes(btn, "Press")
		)
	end

	local deactivateTrove = trove:extend()
	deactivateTrove:add(function()
		btn:SetAttribute("ButtonPressed", false)
		utils.tweenMaybeInstant(btn, { CFrame = originalCFrame }, utils.tweenConfigFromAttributes(btn, "Press"))
		utils.connectActivation(trove, btn, pressButton)
	end)

	glowButton(deactivateTrove, btn)

	local duration = Duration(btn)
	if duration >= 0 then
		task.delay(duration, function()
			deactivateTrove:clean()
		end)
	end

	deactivateTrove:connect(btn:GetAttributeChangedSignal("ButtonPressed"), function()
		if not ButtonPressed(btn) then
			deactivateTrove:clean()
		end
	end)
end

local function tryUpdateIdOfButton(btn: Instance)
	local id = ButtonId(btn)
	if id then
		updateId(id)
	end
end

local self = {} :: utils.KitScript<typeof(ButtonAttributes) & typeof(ButtonActivatedAttributes) & {
	idToButtonsPressed: utils.MapSet<string, BasePart>,
	glowButton: (trove: utils.Trove, btn: BasePart, flash: boolean?) -> (),
	updateId: (id: string) -> (),
}>
self.type = "KitScript"
self.idToButtonsPressed = idToButtonsPressed
self.glowButton = glowButton
self.updateId = updateId

for key, value in ButtonAttributes do
	self[key] = value
end

for key, value in ButtonActivatedAttributes do
	self[key] = value
end

function self:run(kit: utils.Kit)
	local Button = kit:tag("Button", utils.isBasePart)
	local ButtonActivated = kit:tag("ButtonActivated")

	ButtonActivated:onLoaded(function(trove, ba)
		local id = ButtonId(ba)
		if id then
			idToButtonActivateds:add(id, ba)
		end

		trove:connect(ba:GetAttributeChangedSignal("ButtonId"), function()
			local id = ButtonId(ba)
			if id then
				idToButtonActivateds:add(id, ba)
			end
		end)
	end)

	Button:onActivated(pressButton)

	Button:onLoaded(function(trove, btn)
		trove:connect(btn:GetAttributeChangedSignal("ButtonPressed"), function()
			local id = ButtonId(btn)

			if not ButtonPressed(btn) then
				if id then
					idToButtonsPressed:remove(id, btn)
				end
			end

			if id then
				updateId(id)
			end
		end)

		-- try update once to set initial properties
		tryUpdateIdOfButton(btn)

		trove:connect(btn:GetAttributeChangedSignal("ButtonId"), function()
			-- TOOD
		end)
	end)
end

return self
