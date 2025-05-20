--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- TODO: button timers and tick sounds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local ButtonAttributes = require(script:WaitForChild("ButtonAttributes"))
local ButtonEnabledAttributes = require(script:WaitForChild("ButtonEnabledAttributes"))
export type ActivatedBy = ButtonAttributes.ActivatedBy
local ButtonId = ButtonAttributes.ButtonId
local ButtonPressed = ButtonAttributes.ButtonPressed
local Duration = ButtonAttributes.Duration
local PlaySound = ButtonAttributes.PlaySound
local PressOffset = ButtonAttributes.PressOffset
local glowButton = require(script:WaitForChild("glowButton"))
local updateButtonEnabled = require(script:WaitForChild("updateButtonEnabled"))

local idToButtonEnableds: std.MapSet<string, Instance> = std.collections.MapSet()
local idToButtonsPressed: std.MapSet<string, BasePart> = std.collections.MapSet()

local function updateId(id: string)
	local ButtonEnableds = idToButtonEnableds:get(id)
	if not ButtonEnableds then
		return
	end

	local isPressed = next(idToButtonsPressed:get(id)) ~= nil

	for ba in ButtonEnableds do
		-- updateButtonEnabled(ba, isPressed)
		task.spawn(updateButtonEnabled, ba, isPressed)
	end
end

local function pressButton(trove: std.Trove, btn: BasePart)
	local id = ButtonId(btn)

	if ButtonPressed(btn) or not id then
		return
	end

	prelude.Activatable:set(btn, false)
	btn:SetAttribute("ButtonPressed", true)
	idToButtonsPressed:add(id, btn)

	if PlaySound(btn) then
		prelude.inferAndPlaySound(btn, prelude.AUDIO_ASSETS["core/towerSfx/button"], "Press")
	end

	local originalCFrame = btn.CFrame
	local pressOffset = std.physics.intoCFrameOffset(PressOffset(btn))

	if btn.Anchored then
		prelude.tweenMaybeInstant(
			btn,
			{ CFrame = originalCFrame * pressOffset },
			prelude.tweenConfigFromAttributes(btn, "Press")
		)
	end

	local deactivateTrove = trove:extend()
	deactivateTrove:add(function()
		btn:SetAttribute("ButtonPressed", false)
		prelude.Activatable:set(btn, true)
		prelude.tweenMaybeInstant(btn, { CFrame = originalCFrame }, prelude.tweenConfigFromAttributes(btn, "Press"))
	end)

	glowButton(deactivateTrove, btn)

	local duration = Duration(btn)
	if duration > 0 then
		task.delay(duration, function()
			deactivateTrove:clean()
		end)
	end

	deactivateTrove:add(ButtonPressed:changed(btn, function(pressed)
		if not pressed then
			deactivateTrove:clean()
		end
	end))
end

local function tryUpdateIdOfButton(btn: Instance)
	local id = ButtonId(btn)
	if id then
		updateId(id)
	end
end

local self = {} :: std.KitScript<typeof(ButtonAttributes) & typeof(ButtonEnabledAttributes) & {
	idToButtonsPressed: std.MapSet<string, BasePart>,
	glowButton: (trove: std.Trove, btn: BasePart, flash: boolean?) -> (),
	updateId: (id: string) -> (),
}>

self.implements = { KitScript = true }
self.idToButtonsPressed = idToButtonsPressed
self.glowButton = glowButton
self.updateId = updateId

for key, value in ButtonAttributes do
	self[key] = value
end

for key, value in ButtonEnabledAttributes do
	self[key] = value
end

function self:run(kit: std.Kit)
	local Button = kit:tag("Button", prelude.isBasePart)
	local ButtonEnabled = kit:tag("ButtonEnabled")

	ButtonEnabled:onLoaded(function(trove, ba)
		local id = ButtonId(ba)
		if id then
			idToButtonEnableds:add(id, ba)
		end

		trove:add(ButtonId:changed(ba, function(id)
			if id then
				idToButtonEnableds:add(id, ba)
			end
		end))
	end)

	Button:onActivated(pressButton)

	Button:onLoaded(function(trove, btn)
		trove:add(ButtonPressed:changed(btn, function(id)
			local id = ButtonId(btn)

			if not ButtonPressed(btn) then
				if id then
					idToButtonsPressed:remove(id, btn)
				end
			end

			if id then
				updateId(id)
			end
		end))

		-- try update once to set initial properties
		tryUpdateIdOfButton(btn)

		trove:add(ButtonId:changed(btn, function(id)
			-- TOOD
		end))
	end)
end

return self
