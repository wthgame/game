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
local PressOffset = ButtonAttributes.PressOffset
local PressTime = ButtonAttributes.PressTime
local PressEasingStyle = ButtonAttributes.PressEasingStyle
local PressEasingDirection = ButtonAttributes.PressEasingDirection
local glowButton = require(script:WaitForChild("glowButton"))
local updateButtonActivated = require(script:WaitForChild("updateButtonActivated"))

local buttonActivatedsById: utils.MapSet<string, Instance> = utils.MapSet()
local buttonsPressedById: utils.MapSet<string, BasePart> = utils.MapSet()

local function updateId(id: string)
	local buttonActivateds = buttonActivatedsById[id]
	if not buttonActivateds then
		return
	end

	local isPressed = next(buttonsPressedById:get(id)) ~= nil

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
	utils.playSound(utils.SOUND_ASSETS.button)

	btn:SetAttribute("ButtonPressed", true)
	buttonsPressedById:add(id, btn)

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
		utils.tweenMaybeInstant(btn, { CFrame = originalCFrame * finalPressOffset }, {
			time = PressTime(btn),
			easingStyle = PressEasingStyle(btn),
			easingDirection = PressEasingDirection(btn),
		})
	end

	local deactivateTrove = trove:extend()
	deactivateTrove:add(function()
		btn:SetAttribute("ButtonPressed", false)
		utils.tweenMaybeInstant(btn, { CFrame = originalCFrame }, {
			time = PressTime(btn),
			easingStyle = PressEasingStyle(btn),
			easingDirection = PressEasingDirection(btn),
		})

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
	buttonsPressedById: utils.MapSet<string, BasePart>,
	trackButtonActivatedById: (id: string, buttonActivated: Instance) -> (),
	trackButtonPressedById: (id: string, button: BasePart) -> (),
	untrackButtonPressedById: (id: string, button: BasePart) -> (),
	getButtonsPressedById: (id: string) -> utils.Set<BasePart>,
	glowButton: (trove: utils.Trove, btn: BasePart, flash: boolean?) -> (),
	updateId: (id: string) -> (),
}>
self.type = "KitScript"
self.buttonsPressedById = buttonsPressedById
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
			buttonActivatedsById:add(id, ba)
		end

		trove:connect(ba:GetAttributeChangedSignal("ButtonId"), function()
			local id = ButtonId(ba)
			if id then
				buttonActivatedsById:add(id, ba)
			end
		end)
	end)

	Button:connectActivation(pressButton)

	Button:onLoaded(function(trove, btn)
		trove:connect(btn:GetAttributeChangedSignal("ButtonPressed"), function()
			local id = ButtonId(btn)

			if not ButtonPressed(btn) then
				if id then
					buttonsPressedById:remove(id, btn)
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
