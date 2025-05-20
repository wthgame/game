--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local Button = require("./Button")
local ButtonId = Button.ButtonId
local idToButtonsPressed = Button.idToButtonsPressed

export type DialogWrapBehavior = "NoWrap" | "Wrap"
export type DialogEffect = "Gradient" | "Wave"

export type DialogTextSegment = {
	canSkip: boolean,
	font: Font,
	color: Color3,
	effect: DialogEffect,
}

export type DialogText = {
	type: "text",
	awaitWriteFinish: boolean,
	awaitTextFade: boolean,
	deleteAfter: number,
	wrapBehavior: DialogWrapBehavior,
	segments: { DialogTextSegment },
}

export type DialogChoose = {
	type: "choose",
	label: string,
	actions: { DialogAction },
}

export type DialogPlaySound = {
	type: "playSound",
	awaitFinish: boolean,
	sound: Sound | string | nil,
	gameAsset: string?,
	spatial: boolean?,
}

export type DialogPressButton = {
	type: "pressButton",
	id: string,
	-- ???
	pressed: true | false | boolean | "toggle" | nil,
}

export type DialogAction = DialogText | DialogPlaySound | DialogChoose | DialogPressButton

local AwaitWriteFinish = prelude.attribute("AwaitWriteFinish", prelude.isBoolean, true)
local AwaitTextFade = prelude.attribute("AwaitTextFade", prelude.isBoolean, true)
local DeleteAfter = prelude.attribute("DeleteAfter", prelude.isPositiveNumber, 1)
local WrapBehavior: std.Attribute<DialogWrapBehavior> = (
	prelude.attribute("WrapBehavior", prelude.t.literal("NoWrap", "Wrap"), "NoWrap")
)

local AwaitFinish = prelude.attribute("AwaitFinish", prelude.isBoolean, true)
local Sound = prelude.attribute("Sound", prelude.isString)
local PlayFromGameAssets = prelude.attribute("PlayFromGameAssets", std.audio.isAudioAsset)
local Spatial = prelude.attribute("Spatial", prelude.isBoolean, false)

local logger = prelude.createLogger("Dialog")

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function collectActionsFromSequence(sequence: Instance): { DialogAction }
	local collected: { DialogAction } = {}
	for _, child in sequence:GetChildren() do
		local index = tonumber(child.Name:match("%d+"))
		if not index then
			continue
		end

		local actionType = sequence:GetAttribute("DialogActionType")

		if not actionType then
			logger:warn("No DialogActionType attribute in DialogAction", child:GetFullName())
			continue
		end

		if not prelude.isString(actionType) then
			logger:warn(
				"Expected DialogActionType attribute in DialogSequence",
				sequence:GetFullName() .. "'s child",
				child:GetFullName(),
				"to be a string, got:",
				typeof(actionType)
			)
			continue
		end

		local action: DialogAction? = nil

		if actionType == "Text" then
		elseif actionType == "Choose" then
		elseif actionType == "PlaySound" then
			local sound = child:FindFirstChildOfClass("Sound")
			local soundAttribute = Sound(child)
			local asset = PlayFromGameAssets(child)
			if not sound or not soundAttribute or not asset then
				logger:warn(
					"DialogAction of type PlaySound",
					child:GetFullName(),
					"requires a Sound child, a Sound attribute, or a PlayFromGameAssets attribute."
				)
				continue
			end
			action = {
				type = "playSound",
				awaitFinish = AwaitFinish(child),
				sound = sound or soundAttribute,
				gameAsset = asset,
				spatial = Spatial(child),
			}
		elseif actionType == "PressButton" then
			action = {
				type = "pressButton",
				id = ButtonId:assert(child) :: string,
				pressed = false,
			}
		end

		if not action then
			logger:warn("Unknown DialogActionType in DialogAction", child:GetFullName() .. ":", actionType)
			continue
		end

		collected[index] = action
	end
	return collected
end

local function runDialogSequence(trove: std.Trove, sequence: Instance, activationTrove: std.Trove)
	local actions = collectActionsFromSequence(sequence)
end

function self:run(kit: std.Kit)
	local DialogSequence = kit:tag("DialogSequence")
	DialogSequence:onActivated(runDialogSequence)
end

return self
