--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")
-- local UserInputService = game:GetService("UserInputService")

local attributes = require("./attributes")
local touch = require("./touch")
local isToucherValid = touch.isToucherValid
local t = require("./packages/t")
local trove = require("./packages/trove")

-- TODO: ScreenPress, ControllerCode, HumanoidStateChanged
export type ActivationMode = "Touch" | "Prompt" | "Click" | "KeyCode"

-- TODO: split Active to Enabled, for controlling if a mechanic can be activated
-- and Active, for if the mechanic should do something. Most likely will do
-- after initial alpha
local Active = attributes.attribute("Active", t.boolean, false)
local ActivationMode: attributes.InstanceAttribute<ActivationMode> = (
	attributes.attribute("ActivationMode", t.literal("Touch", "Prompt", "Click", "Control"))
) :: any
local MaxActivationDistance = attributes.attribute("MaxActivationDistance", t.number, math.huge)
local ActivationKeyCode = attributes.attribute("ActivationKeyCode", t.enum(Enum.KeyCode) :: t.check<Enum.KeyCode>)

local function createActivationClickDetector(trove: trove.Trove, parent: Instance)
	local clickDetector = trove:add(Instance.new("ClickDetector"))
	clickDetector.Name = "ActivationClickDetector"
	clickDetector.Parent = parent
	return clickDetector
end

local function getActivationClickDetector(trove: trove.Trove, parent: Instance)
	local detect = parent:FindFirstChild("ActivationClickDetector", true) :: ClickDetector

	if not detect then
		detect = createActivationClickDetector(trove, parent)
	elseif detect.ClassName ~= "ClickDetector" then
		-- someones trying to troll the game
		detect.Name ..= "_FAKE"
		detect = createActivationClickDetector(trove, parent)
	end

	detect.MaxActivationDistance = MaxActivationDistance(parent)

	return detect
end

local function createActivationProximityPrompt(trove: trove.Trove, parent: Instance)
	local clickDetector = trove:add(Instance.new("ProximityPrompt"))
	clickDetector.Name = "ActivationProximityPrompt"
	clickDetector.Parent = parent
	return clickDetector
end

local function getActivationProximityPrompt(trove: trove.Trove, parent: Instance)
	local prompt = parent:FindFirstChild("ActivationProximityPrompt", true) :: ProximityPrompt

	if not prompt then
		prompt = createActivationProximityPrompt(trove, parent)
	elseif prompt.ClassName ~= "ProximityPrompt" then
		-- someones trying to troll the game
		prompt.Name ..= "_FAKE"
		prompt = createActivationProximityPrompt(trove, parent)
	end

	prompt.MaxActivationDistance = MaxActivationDistance(parent)

	return prompt
end

-- local function connectToKeycodeInput<T>(trove: trove.Trove, connectTo: T & Instance, onActivated: (T) -> ())
-- 	trove:connect(UserInputService.InputBegan, function(io, gc)
-- 		if not gc and Active(connectTo) and io == ActivationKeyCode(connectTo) then
-- 			onActivated(connectTo)
-- 		end
-- 	end)
-- end

local function connectActivationOnce<T>(
	outerTrove: trove.Trove,
	activationTrove: trove.Trove,
	connectTo: T & Instance,
	onActivated: (outerTrove: trove.Trove, instance: T, activationTrove: trove.Trove) -> (),
	defaultMode: ActivationMode?
)
	local mode: ActivationMode? = ActivationMode(connectTo) or defaultMode

	if mode then
		if mode == "Touch" then
			if connectTo:IsA("BasePart") then
				activationTrove:connect(connectTo.Touched, function(toucher)
					if Active(connectTo) and isToucherValid(connectTo, toucher) then
						onActivated(outerTrove, connectTo, activationTrove)
					end
				end)
			end
		elseif mode == "Click" then
			local detect: ClickDetector? = if connectTo:IsA("ClickDetector")
				then connectTo
				elseif connectTo:IsA("BasePart") then getActivationClickDetector(activationTrove, connectTo)
				else nil

			if detect then
				activationTrove:connect(detect.MouseClick, function(player: Player)
					-- TODO: do we need this?
					if Active(connectTo) and player == Players.LocalPlayer then
						onActivated(outerTrove, connectTo, activationTrove)
					end
				end)
			end
		elseif mode == "Prompt" then
			local prompt: ProximityPrompt? = if connectTo:IsA("ProximityPrompt")
				then connectTo
				elseif connectTo:IsA("BasePart") then getActivationProximityPrompt(activationTrove, connectTo)
				else nil

			if prompt then
				activationTrove:connect(prompt.Triggered, function(player: Player)
					-- TODO: do we need this?
					if Active(connectTo) and player == Players.LocalPlayer then
						onActivated(outerTrove, connectTo, activationTrove)
					end
				end)
			end
			-- elseif mode == "KeyCode" then
			-- 	local inputTrove = activationTrove:extend()
			-- 	inputTrove:connect(connectTo:GetAttributeChangedSignal("ActivationKeyCode"), function()
			-- 		-- local keycode = ActivationKeyCode(connectTo)
			-- 		-- if keycode then
			-- 		-- 	-- return connectToKeycodeInput(inputTrove, connectTo, onActivated)
			-- 		-- end
			-- 		inputTrove:clean()
			-- 	end)
			-- 	-- local keycode = ActivationKeyCode(connectTo)
			-- 	-- if keycode then
			-- 	-- 	-- connectToKeycodeInput(inputTrove, connectTo, onActivated)
			-- 	-- end
		end
	end
end

--[=[
    @within KitStd

    Calls the callback when the connected instance is activated based on it's
    `ActivationMode` attribute:

    * If `ActivationMode == "Touch" and connectTo:IsA("BasePart")`, activates
      when the supported instances touch the connected instance
    * If `ActivationMode == "Prompt" and connectTo:IsA("BasePart")`,
      activates when a `connectTo.ActivationProximityPrompt` ProximityPrompt -
      or creates one - is triggered. `MaxActivationDistance` is also set.
    * If `ActivationMode == "Click" and connectTo:IsA("BasePart")`,
      activates when a `connectTo.ActivationClickDetector` ClickDetector - or
      creates one- is triggered. `MaxActivationDistance` is also set.
    * If `ActivationMode == "KeyCode"`, it activates when `ActivationKeyCode`
      is triggered.

    `onActivated` receives the connected instance so callbacks can be cached.

    `onActivated` is only called if the `Active` attribute is enabled.

    Once activated, the consumer should cleanup the given trove and reconnect
    once it is deactivated.

    This implements the following attributes for the connected instance:
    * `ActivationMode`
    * `MaxActivationDistance`
    * `ActivationKeyCode` if `ActivationMode == "Control"`
    * `SupportsCharacter` if `ActivationMode == "Control"`
    * `SupportsBoxes` if `ActivationMode == "Control"`
    * `BoxesRequiresMatchingId` if `ActivationMode == "Control"`
    * `RequiredBoxId` if `ActivationMode == "Control"`

    ```Lua
    Self:onLoaded(function(trove, self)
        local activationTrove = trove:extend()
        local isActivated = false

        local function onSelfActivated()
            if not isActivated then
                isActivated = true
                activationTrove:clean()
                print("Activated!")

                task.delay(3, function()
                    isActivated = false
                    activationTrove = trove:extend()
                    prelude.connectActivation(activationTrove, connectTo, onSelfActivated)
                    print("Deactivated!")
                end)
            end
        end

        prelude.connectActivation(activationTrove, connectTo, onSelfActivated)
    end)
    ```
]=]
local function connectActivation<T>(
	outerTrove: trove.Trove,
	connectTo: T & Instance,
	onActivated: (outerTrove: trove.Trove, instance: T, activationTrove: trove.Trove) -> (),
	defaultMode: ActivationMode?
)
	local activationTrove = outerTrove:extend()
	local activationInnerTrove = activationTrove:extend()
	connectActivationOnce(outerTrove, activationInnerTrove, connectTo, onActivated, defaultMode)
	activationTrove:connect(connectTo:GetAttributeChangedSignal(ActivationMode.name), function()
		activationInnerTrove:clean()
		activationInnerTrove = activationTrove:extend()
		connectActivationOnce(outerTrove, activationInnerTrove, connectTo, onActivated, defaultMode)
	end)
	return activationTrove
end

return {
	connectActivation = connectActivation,
	Active = Active,
	ActivationMode = ActivationMode,
	MaxActivationDistance = MaxActivationDistance,
	ActivationKeyCode = ActivationKeyCode,
}
