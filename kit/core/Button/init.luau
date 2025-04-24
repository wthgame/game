--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: this is a very rough implementation

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
local bindActivationToTrove = require(script:WaitForChild("bindActivationToTrove"))
local flashButtonGlow = require(script:WaitForChild("flashButtonGlow"))
local updateButtonActivated = require(script:WaitForChild("updateButtonActivated"))

local buttonActivatedsById: utils.Map<string, utils.Set<Instance>> = {}

local function trackButtonActivatedById(id: string, buttonActivated: Instance)
	local existing = buttonActivatedsById[id]
	if existing then
		existing[buttonActivated] = true
	else
		buttonActivatedsById[id] = { [buttonActivated] = true }
	end
end

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

local function getButtonsPressedById(id: string): utils.Set<BasePart>
	return buttonsPressedById[id] or {}
end

local function updateId(id: string)
	local buttonActivateds = buttonActivatedsById[id]
	if not buttonActivateds then
		return
	end

	local isPressed = next(getButtonsPressedById(id)) ~= nil

	for ba in buttonActivateds do
		-- updateButtonActivated(ba, isPressed)
		task.spawn(updateButtonActivated, ba, isPressed)
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
	end)

	flashButtonGlow(deactivateTrove, btn)

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
	buttonsPressedById: utils.Map<string, utils.Set<BasePart>>,
	trackButtonActivatedById: (id: string, buttonActivated: Instance) -> (),
	trackButtonPressedById: (id: string, button: BasePart) -> (),
	untrackButtonPressedById: (id: string, button: BasePart) -> (),
	getButtonsPressedById: (id: string) -> utils.Set<BasePart>,
	bindActivationToTrove: (trove: utils.Trove, btn: BasePart, onActivated: () -> ()) -> (),
	updateId: (id: string) -> (),
}>
self.type = "KitScript"
self.buttonsPressedById = buttonsPressedById
self.trackButtonActivatedById = trackButtonActivatedById
self.trackButtonPressedById = trackButtonPressedById
self.untrackButtonPressedById = untrackButtonPressedById
self.getButtonsPressedById = getButtonsPressedById
self.bindActivationToTrove = bindActivationToTrove
self.updateId = updateId

for key, value in ButtonAttributes do
	self[key] = value
end

for key, value in ButtonActivatedAttributes do
	self[key] = value
end

function self:run(kit: utils.Kit)
	local Button = kit:tag("Button", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)
	local ButtonActivated = kit:tag("ButtonActivated")

	ButtonActivated:onLoaded(function(trove, ba)
		local id = ButtonId(ba)
		if id then
			trackButtonActivatedById(id, ba)
		end

		trove:connect(ba:GetAttributeChangedSignal("ButtonId"), function()
			local id = ButtonId(ba)
			if id then
				trackButtonActivatedById(id, ba)
			end
		end)
	end)

	Button:onLoaded(function(trove, btn)
		local activationTrove = trove:extend()
		local function activateSelf()
			activationTrove:clean()
			activate(trove, btn)
		end

		bindActivationToTrove(activationTrove, btn, activateSelf)

		trove:connect(btn:GetAttributeChangedSignal("ActivatedBy"), function()
			activationTrove:clean()
			activationTrove = trove:extend()
			bindActivationToTrove(activationTrove, btn, activateSelf)
		end)

		trove:connect(btn:GetAttributeChangedSignal("ButtonPressed"), function()
			local id = ButtonId(btn)

			activationTrove:clean()
			if not ButtonPressed(btn) then
				activationTrove = trove:extend()
				bindActivationToTrove(activationTrove, btn, activateSelf)
				if id then
					untrackButtonPressedById(id, btn)
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
