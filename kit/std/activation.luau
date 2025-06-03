--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local attributes = require("./attributes")
local t = require("./packages/t")
local touch = require("./touch")
local trove = require("./packages/trove")

type ActivationBehaviorImpl = {
	predicate: ((instance: Instance) -> boolean)?,
	implement: (
		trove: trove.Trove,
		instanceTrove: trove.Trove,
		instance: Instance,
		onActivated: (trove: trove.Trove, instance: Instance) -> ()
	) -> (),
}

local localPlayer = Players.LocalPlayer

--- @class KitStdActivation
--- Implements activation for kit objects.
local activation = {}

--- @prop Activatable Attribute<boolean>
--- @within KitStdActivation
--- Whether if a kit object can be activated.
activation.Activatable = attributes.Attribute("Activatable", t.boolean, false)

--- @prop Enabled Attribute<boolean>
--- @within KitStdActivation
--- TBA
activation.Enabled = attributes.Attribute("Enabled", t.boolean, false)

--- @prop ActivationBehavior Attribute<ActivationBehavior>
--- @within KitStdActivation
--- How to handle activation behavior.
activation.ActivationBehavior = attributes.Attribute("ActivationBehavior", t.string)

--- @prop MaxActivationDistance Attribute<number?>
--- @within KitStdActivation
--- TBA
activation.MaxActivationDistance = attributes.Attribute("MaxActivationDistance", t.numberPositive)

--- @prop ActivationKeyCode Attribute<Enum.KeyCode?>
--- @within KitStdActivation
--- TBA
activation.ActivationKeyCode = attributes.Attribute("ActivationKeyCode", t.enum(Enum.KeyCode))

--- @prop ActivationInterval Attribute<number?>
--- @within KitStdActivation
--- TBA
activation.ActivationInterval = attributes.Attribute("ActivationInterval", t.numberPositive)

--- @prop ActivationHumanoidStateType Attribute<Enum.HumanoidStateType?>
--- @within KitStdActivation
--- TBA
activation.ActivationHumanoidStateType = (
	attributes.Attribute("ActivationHumanoidStateType", t.enum(Enum.HumanoidStateType))
)

local function ActivationBehaviorImpl(x: ActivationBehaviorImpl)
	return table.freeze(x)
end

local function createActivationClickDetector(trove: trove.Trove, parent: Instance)
	local clickDetector = trove:add(Instance.new("ClickDetector"))
	clickDetector.Name = "ActivationClickDetector"
	clickDetector.MaxActivationDistance = math.huge
	clickDetector.Parent = parent
	return clickDetector
end

local function getActivationClickDetector(trove: trove.Trove, parent: Instance)
	local detect = parent:FindFirstChild("ActivationClickDetector") :: ClickDetector

	if not detect then
		detect = createActivationClickDetector(trove, parent)
	elseif detect.ClassName ~= "ClickDetector" then
		-- someones trying to troll the game
		detect.Name ..= "_FAKE"
		detect = createActivationClickDetector(trove, parent)
	end

	local max = activation.MaxActivationDistance(parent)
	if max then
		detect.MaxActivationDistance = max
	end

	return detect
end

local function createActivationProximityPrompt(trove: trove.Trove, parent: Instance)
	local prompt = trove:add(Instance.new("ProximityPrompt"))
	prompt.Name = "ActivationProximityPrompt"
	prompt.ActionText = ""
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = math.huge
	prompt.Parent = parent
	return prompt
end

local function getActivationProximityPrompt(trove: trove.Trove, parent: Instance)
	local prompt = parent:FindFirstChild("ActivationProximityPrompt") :: ProximityPrompt

	if not prompt then
		prompt = createActivationProximityPrompt(trove, parent)
	elseif prompt.ClassName ~= "ProximityPrompt" then
		-- someones trying to troll the game
		prompt.Name ..= "_FAKE"
		prompt = createActivationProximityPrompt(trove, parent)
	end

	local max = activation.MaxActivationDistance(parent)
	if max then
		prompt.MaxActivationDistance = max
	end

	trove:add(function()
		prompt.Enabled = false
	end)

	prompt.Enabled = true

	return prompt
end

local activationBehaviorImpls = table.freeze({
	Touch = ActivationBehaviorImpl {
		predicate = t.instanceIsA("BasePart"),
		implement = function(trove, instanceTrove, instance, onActivated)
			trove:connect((instance :: BasePart).Touched, function(toucher: BasePart)
				if touch.isToucherValid(instance, toucher) then
					onActivated(instanceTrove, instance)
				end
			end)
		end,
	},
	Prompt = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			local prompt: ProximityPrompt? = if instance:IsA("ProximityPrompt")
				then instance
				elseif instance:IsA("BasePart") then getActivationProximityPrompt(trove, instance)
				else nil

			if prompt then
				trove:connect(prompt.Triggered, function(player)
					if player == localPlayer then
						onActivated(instanceTrove, instance)
					end
				end)
			end
		end,
	},
	Click = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			local click: ClickDetector? = if instance:IsA("ClickDetector")
				then instance
				elseif instance:IsA("BasePart") then getActivationClickDetector(trove, instance)
				else nil

			if click then
				trove:connect(click.MouseClick, function(player)
					if player == localPlayer then
						onActivated(instanceTrove, instance)
					end
				end)
			end
		end,
	},
	KeyCode = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			trove:connect(UserInputService.InputBegan, function(inputObject, gameProcessed)
				if not gameProcessed and inputObject == activation.ActivationKeyCode(instance) then
					onActivated(instanceTrove, instance)
				end
			end)
		end,
	},
	HumanoidStateChanged = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			-- TODO
		end,
	},
	Interval = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			-- TODO
		end,
	},
	Node = ActivationBehaviorImpl {
		implement = function(trove, instanceTrove, instance, onActivated)
			-- TODO
		end,
	},
})

local function implementActivationBehavior<T>(
	trove: trove.Trove,
	instanceTrove: trove.Trove,
	instance: T & Instance,
	onActivated: (trove: trove.Trove, instance: T) -> ()
)
	local behavior = activation.ActivationBehavior(instance)
	local behaviorImpl: ActivationBehaviorImpl? = activationBehaviorImpls[behavior]
	if behaviorImpl then
		if behaviorImpl.predicate and not behaviorImpl.predicate(instance) then
			return
		end
		behaviorImpl.implement(trove, instanceTrove, instance, onActivated :: any)
	end
end

--- @within KitStdActivation
--- Calls the callback when the connected instance is activated based on it's
--- `ActivationMode` attribute:
---
--- * If `ActivationMode == "Touch" and connectTo:IsA("BasePart")`, activates
---   when the supported instances touch the connected instance
--- * If `ActivationMode == "Prompt" and connectTo:IsA("BasePart")`,
---   activates when a `connectTo.ActivationProximityPrompt` ProximityPrompt -
---   or creates one - is triggered. `MaxActivationDistance` is also set.
--- * If `ActivationMode == "Click" and connectTo:IsA("BasePart")`,
---   activates when a `connectTo.ActivationClickDetector` ClickDetector - or
---   creates one- is triggered. `MaxActivationDistance` is also set.
--- * If `ActivationMode == "KeyCode"`, it activates when `ActivationKeyCode`
---   is triggered.
---
--- `onActivated` receives the connected instance so callbacks can be cached.
---
--- `onActivated` is only called if the `Active` attribute is enabled.
---
--- Once activated, the consumer should cleanup the given trove and reconnect
--- once it is deactivated.
---
--- This implements the following attributes for the connected instance:
--- * `ActivationMode`
--- * `MaxActivationDistance`
--- * `ActivationKeyCode` if `ActivationMode == "Control"`
--- * `SupportsCharacter` if `ActivationMode == "Control"`
--- * `SupportsBoxes` if `ActivationMode == "Control"`
--- * `BoxesRequiresMatchingId` if `ActivationMode == "Control"`
--- * `RequiredBoxId` if `ActivationMode == "Control"`
---
--- ```luau
--- Self:onLoaded(function(trove, self)
---     local activationTrove = trove:extend()
---     local isActivated = false
---
---     local function onSelfActivated()
---         if not isActivated then
---             isActivated = true
---             activationTrove:clean()
---             print("Activated!")
---
---             task.delay(3, function()
---                 isActivated = false
---                 activationTrove = trove:extend()
---                 prelude.connectActivation(activationTrove, connectTo, onSelfActivated)
---                 print("Deactivated!")
---             end)
---         end
---     end
---
---     prelude.connectActivation(activationTrove, connectTo, onSelfActivated)
--- end)
--- ```
function activation.onActivated<T>(
	instanceTrove: trove.Trove,
	instance: T & Instance,
	onActivated: (trove: trove.Trove, instance: T) -> ()
)
	local trove = instanceTrove:extend()
	local activationTrove = trove:extend()

	if activation.Activatable(instance) then
		implementActivationBehavior(activationTrove, trove, instance, onActivated)
	end

	trove:add(activation.Activatable:changed(instance, function(new)
		activationTrove = activationTrove:clean()
		activationTrove = trove:extend()
		if new then
			implementActivationBehavior(activationTrove, trove, instance, onActivated)
		end
	end))
end

return table.freeze(activation)
