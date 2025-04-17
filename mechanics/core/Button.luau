--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local BUTTON_ACTIVATED_TWEEN_CONFIG: utils.TweenConfig = { time = 0.5, easingStyle = Enum.EasingStyle.Quart }

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Button"

local function getPartButtonColor(part: BasePart): Color3
	return utils.roundColor(utils.castCheck(part:GetAttribute("Color3"), utils.t.Color3) or part.Color)
end

function mech:init(wth)
	local Button: utils.Entity<BasePart> = wth:useTag("Button", utils.t.instanceIsA("BasePart"))
	local Activated: utils.Entity = wth.world:component()
	local Cooldown = wth:useAttribute("Cooldown", Button, utils.t.numberPositive, 0)
	local Duration = wth:useAttribute(
		"Duration",
		Button,
		-- NOTE: duration of zero means indefinite, mirroring obby creator
		utils.t.union(utils.t.numberPositive, utils.t.literal(0)) :: utils.Check<number>,
		1
	)
	local ActiveOffset = wth:useAttribute(
		"ActiveOffset",
		Button,
		utils.t.union(utils.t.Vector3, utils.t.CFrame),
		Vector3.new(0, -0.5, 0)
	)

	local ButtonActivated: utils.Entity<Instance> = wth:useTag("ButtonActivated")
	local Invert = wth:useAttribute("Invert", ButtonActivated, utils.t.boolean, false)

	local activeColors: { [Color3]: true } = {}

	local queryButtons = wth.world:query(Button, Cooldown, Duration, ActiveOffset):without(Activated):cached()
	local queryButtonActivateds = wth.world:query(ButtonActivated):cached()

	local function deactivate(id: utils.Entity, button: BasePart, color: Color3, originalCFrame: CFrame)
		wth.world:remove(id, Activated)
		activeColors[color] = nil
		utils.tween(button, { CFrame = originalCFrame }, BUTTON_ACTIVATED_TWEEN_CONFIG)
	end

	local function activate(id: utils.Entity, button: BasePart, duration: number, offset: Vector3 | CFrame)
		wth.world:add(id, Activated)

		local originalCFrame = button.CFrame
		-- local originalMaterial = button.Material

		local buttonActivatedCFrame = button.CFrame
		if typeof(offset) == "Vector3" then
			buttonActivatedCFrame *= CFrame.new(offset)
		else
			buttonActivatedCFrame *= offset
		end

		-- button.Material = Enum.Material.Neon
		utils.tween(button, { CFrame = buttonActivatedCFrame }, BUTTON_ACTIVATED_TWEEN_CONFIG)

		local color = getPartButtonColor(button)
		activeColors[color] = true

		local isFinite = duration ~= 0 and duration < math.huge
		if isFinite then
			task.delay(duration, deactivate, id, button, color, originalCFrame)
		end
	end

	local function checkButtons()
		for id, button, cooldown, duration, offset in queryButtons:iter() do
			if not utils.isCharacterTouchingPart(button) then
				continue
			end

			activate(id, button, duration, offset)
		end
	end

	local function checkButtonActivated()
		for id, ba in queryButtonActivateds:iter() do
			local color: Color3?
			local instanceColor = ba:GetAttribute("Color") :: Color3?
			if instanceColor and utils.t.Color3(instanceColor) then
				color = utils.roundColor(instanceColor)
			else
				if ba:IsA("BasePart") then
					color = utils.roundColor(ba.Color)
				end
			end

			if not color then
				continue
			end

			local isActive = false

			for active in activeColors do
				if active == color then
					isActive = true
					break
				end
			end

			-- PERF: fast pass inactive colors
			local isInactive = not isActive
			if ba:IsA("BasePart") then
				if isInactive then
					ba.CanCollide = false
					ba.Transparency = 1
					continue
				else
					ba.CanCollide = true
					ba.Transparency = 0
				end

				continue
			end
		end
	end

	wth:schedule(checkButtons, checkButtonActivated)
end

return mech

--[[
    --!strict

    -->insert-repository-warning<--

    local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

    local runService: RunService = game:GetService("RunService")
    local players: Players = game:GetService("Players")
    local localPlayer = players.LocalPlayer :: Player
    local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

    local handleCache = require(script.CacheHandler)
    type Button = handleCache.Button

    local textReplaceChar = "`"

    return function(scope: _T.Variables)
	local button, trove, shared, utility, communicators = scope.parent, scope.trove, scope.shared, scope.utility, scope.communicators
	if not button then return end

	-- check if cache exists, if not then take care of the cache from now on --
	if shared.button_cache == nil then handleCache(scope) end
	local cache = shared.button_cache

	-- initialize button --
	local buttonPart: Instance? = button:FindFirstChild("ButtonPart")
	local configurations: Instance? = button:FindFirstChild("ButtonConfigurations")
	local timerTextLabel: TextLabel? = button:FindFirstChildWhichIsA("TextLabel")
	if (not (buttonPart and buttonPart:IsA("BasePart"))) or not configurations then return end

	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)
	currentTrove:AttachToInstance(button)
	currentTrove:Add(function() cache.Buttons[button] = nil end)

	local currentButton: Button = {
		Button = buttonPart,
		Configuration = configurations,
		Color = utility.roundColor(buttonPart.Color),
		Pressed = currentTrove:Construct(Instance, "BoolValue"), -- basically Instance.new("BoolValue") but it will also get added to the trove
		ID = utility.generateUID(false, true),
		TotalPresses = 0,
	}

	currentButton.Pressed.Parent = button
	cache.Buttons[button] = currentButton
	local function updatePlatforms(pressed: boolean?)
		communicators.event:Fire(
			"update-button-platforms",
			currentButton,
			if pressed ~= nil then pressed else currentButton.Pressed.Value
		)
	end

	-- button functions --
	local function getTimerColor(): (Color3, Color3)
		if not timerTextLabel then return Color3.new(), Color3.new() end
		local currentColor: Color3 = currentButton.Color
		if utility.hasTag(timerTextLabel, "DefaultColor") then -- default color
			return currentColor, Color3.new(1 - currentColor.R, 1 - currentColor.G, 1 - currentColor.B)
		elseif utility.hasTag(timerTextLabel, "AlternativeDefaultColor") then -- special default color
			return currentColor, utility.subtractHSV(currentColor)
		end

		return timerTextLabel.TextColor3, timerTextLabel.TextStrokeColor3
	end

	local function attachTimer(textLabel: TextLabel)
		local effectGui = playerGui:FindFirstChild("EffectGUI")
		if not effectGui then return end

		local screenText = textLabel:Clone()
		screenText.TextColor3, screenText.TextStrokeColor3 = getTimerColor()
		screenText.TextStrokeTransparency = 0

		local attachValue = Instance.new("ObjectValue")
		attachValue.Name = "AttachToInstance"
		attachValue.Value = textLabel
		attachValue.Parent = screenText

		screenText.Parent = effectGui:FindFirstChild("TimerList")
		local timerTrove = currentTrove:Extend()
		timerTrove:AttachToInstance(textLabel)
		timerTrove:Connect(textLabel.Changed, function() screenText.Text = textLabel.Text end)
		timerTrove:Add(function()
			screenText:Destroy()
			currentTrove:Remove(timerTrove)
		end)
	end
	----------------------

	-- handle button --
	local buttonSound: Instance? = buttonPart:FindFirstChild("Press")
	local debounce = false
	local originalCFrame = buttonPart.CFrame
	local originalMaterial = buttonPart.Material

	updatePlatforms(false)
	currentTrove:Connect(currentButton.Pressed:GetPropertyChangedSignal("Value"), function()
		currentButton.TotalPresses += 1

		local isPressed: boolean = currentButton.Pressed.Value

		local pressOffset = utility.checkConfig(configurations, "ButtonPressOffset")
		local finalPressOffset = CFrame.new(Vector3.yAxis * -0.75)
		if typeof(pressOffset) == "number" then
			finalPressOffset = CFrame.new(Vector3.yAxis * -pressOffset)
		elseif typeof(pressOffset) == "Vector3" then
			finalPressOffset = CFrame.new(pressOffset)
		elseif typeof(pressOffset) == "CFrame" then
			finalPressOffset = pressOffset
		end

		buttonPart.Material = if isPressed
			then utility.getConfig(configurations, "PressedMaterial", Enum.Material.Neon)
			else originalMaterial

		if buttonPart.Anchored and (not utility.isSequence(button)) then
			utility.tween(buttonPart, 1, { CFrame = if isPressed then (originalCFrame * finalPressOffset) else originalCFrame })
		end
		if isPressed and (buttonSound and buttonSound:IsA("Sound")) then buttonSound:Play() end
		updatePlatforms()

		-- the timer should be in this function, no?
		if not isPressed then return end
		local buttonTimer: number = utility.checkConfig(configurations, "Timer") or 0
		if buttonTimer <= 0 then return end
		if not timerTextLabel then return end

		local textOverride: string = utility.checkConfig(configurations, "TimerText") or ""
		local savedTotalPresses: number = currentButton.TotalPresses

		local timerTrove = currentTrove:Extend()
		timerTrove:Add(function() currentTrove:Remove(timerTrove) end)

		local surfaceGui: SurfaceGui = timerTrove:Construct(Instance, "SurfaceGui")
		surfaceGui.Face = Enum.NormalId.Top
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 25

		local currentLabel = timerTextLabel:Clone()
		currentLabel.Parent = surfaceGui
		currentLabel.TextColor3, currentLabel.TextStrokeColor3 = getTimerColor()
		currentLabel.Text = if textOverride then textOverride:gsub(textReplaceChar, tostring(buttonTimer)) else tostring(buttonTimer)

		surfaceGui.Parent = buttonPart
		local guiHidden = utility.checkConfig(configurations, "HideGUI")
		if guiHidden then
			surfaceGui.Enabled = false
		else
			attachTimer(currentLabel)
		end

		local decimalPlaces: number = utility.assureValueType(
			(utility.checkConfig(timerTextLabel, "DecimalPlaces") or utility.checkConfig(configurations, "DecimalPlaces")),
			0
		)

		timerTrove:Add(function()
			if currentButton.TotalPresses ~= savedTotalPresses then return end
			currentButton.Pressed.Value = false
		end)

		local startClock: number = os.clock()
		timerTrove:Connect(runService.Heartbeat, function()
			if currentButton.TotalPresses ~= savedTotalPresses then return timerTrove:Clean() end

			local elapsedTime: number = buttonTimer - (os.clock() - startClock)
			if elapsedTime <= 0 then return timerTrove:Clean() end

			if guiHidden then return end
			local displayTime = string.format(`%0.{decimalPlaces}f`, elapsedTime)
			currentLabel.Text = if textOverride then textOverride:gsub(textReplaceChar, displayTime) else displayTime
		end)
	end)

	if utility.isSequence(button) then return end -- ignore touched connections if the button is within a sequence
	local function activateButton()
		if debounce then return end
		if currentButton.Pressed.Value then return end

		currentButton.Pressed.Value = true
		debounce = true
		task.delay(0.15, function() debounce = false end)
	end

	currentTrove:Connect(buttonPart.Touched, function(toucher: BasePart)
		if not utility.evaluateToucher(buttonPart, toucher, configurations) then return end
		if utility.checkConfig(buttonPart, "Activated") == false then return end

		activateButton()
	end)

	if utility.getConfig(button, "SupportFlips", false) then -- if theres a SupportFlips value in the button ,,, the button will activate once Flipped
		currentTrove:Add(utility.onFlipped(buttonPart, activateButton))
	end
    end
]]

--[[
    --!strict
    -- this is being split into two scripts because i don't want the main script to be cluttered

    -->insert-repository-warning<--

    local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

    local PART_BUFFER = 64 -- every 64 button platforms activated will wait a frame to prevent *some* lag
    local TWEEN_TRANSPARENCY_PROPERTIES: { [string]: string } = { -- things that can have their transparency tweened
	Decal = "Transparency",
	Texture = "Transparency",
	SelectionBox = "Transparency",
	SelectionSphere = "Transparency",
	Frame = "BackgroundTransparency",
	CanvasGroup = "GroupTransparency",
	TextLabel = "TextTransparency",
	ImageLabel = "ImageTransparency",
    }
    local SET_PROPERTIES_ENABLED = { -- these will just have their enabled property change instead of being tweened
	"Beam",
	"ParticleEmitter",
	"Fire",
	"Sparkles",
	"Smoke",
	"Trail",
	"UIStroke",
	"UIGradient",
    }

    export type Button = {
	Button: BasePart,
	Configuration: Instance,
	Color: Color3,
	Pressed: BoolValue,
	ID: string,
	TotalPresses: number,
    }

    local sequencerManager = require(script.SequencerManager)

    return function(scope: _T.Variables)
	local clientObjects, trove, shared, utility, communicators =
		scope.clientObjects, scope.trove, scope.shared, scope.utility, scope.communicators
	if shared.button_cache ~= nil then return end -- already being handled by something else

	local cacheReference: { ButtonActivatedPlatforms: { BasePart }, Buttons: { Button } } = {
		ButtonActivatedPlatforms = {},
		Buttons = {},
	}
	shared.button_cache = cacheReference

	-- Button functions --

	local function hasTimer(currentButton: Button) return (utility.checkConfig(currentButton.Configuration, "Timer") or 0) > 0 end
	local function getTransparency(platform: Instance, isActivated: boolean)
		local enabledTransparency = utility.checkConfig(platform, "SetTransparency") or 0
		local disabledTransparency = if utility.hasTag(platform, "FullHide") then 1 else 0.6
		return if isActivated then enabledTransparency else disabledTransparency
	end

	local function activatePlatform(platform: BasePart, isPressed: boolean, targetButton: Button?)
		local isActivated = isPressed
		if utility.hasTag(platform, "Invert") then isActivated = not isActivated end

		local currentColor = utility.roundColor(utility.getConfig(platform, "ColorOverride", platform.Color))
		if targetButton and currentColor ~= targetButton.Color then return end
		platform:SetAttribute("Activated", isActivated)

		for _, descendant: Instance in platform:GetDescendants() do --rip "asfd", you may or may not be missed
			if descendant.Name == "Activated" and descendant:IsA("BoolValue") then descendant.Value = isActivated end
			if utility.hasTag(descendant, "IgnoreAll") then continue end
			for objectType, property in TWEEN_TRANSPARENCY_PROPERTIES do
				if descendant:IsA(objectType) and not utility.hasTag(descendant, "IgnoreTransparency") then
					utility.tween(descendant, 0.3, { [property] = getTransparency(descendant, isActivated) })
				end
			end

			for _, objectType: string in SET_PROPERTIES_ENABLED do
				if descendant:IsA(objectType) and not utility.hasTag(descendant, "IgnoreEnabled") then
					utility.setInstanceProperty(descendant, "Enabled", isActivated)
				end
			end
		end

		local ignoreAll = utility.hasTag(platform, "IgnoreAll")
		if not (utility.hasTag(platform, "IgnoreCanCollide") or ignoreAll) then platform.CanCollide = isActivated end
		if not (utility.hasTag(platform, "IgnoreTransparency") or utility.hasTag(platform, "Invisible") or ignoreAll) then
			utility.tween(platform, 0.3, { Transparency = getTransparency(platform, isActivated) })
		end
	end

	-- Cache all Platforms --

	for _, platform: Instance in clientObjects:GetDescendants() do -- add any platforms existing before this script runs
		if platform:IsA("BasePart") and utility.isButtonActivatedPlatform(platform) then
			table.insert(cacheReference.ButtonActivatedPlatforms, platform)
			if not utility.hasTag(platform, "IgnoreInitialActivate") then task.spawn(activatePlatform, platform, false) end
		end
	end

	trove:Connect(clientObjects.DescendantAdded, function(descendant: Instance)
		if descendant:IsA("BasePart") and utility.isButtonActivatedPlatform(descendant) then
			table.insert(cacheReference.ButtonActivatedPlatforms, descendant)
			if not utility.hasTag(descendant, "IgnoreInitialActivate") then task.spawn(activatePlatform, descendant, false) end
		end
	end)

	trove:Connect(clientObjects.DescendantRemoving, function(descendant: Instance)
		if not descendant:IsA("BasePart") then return end
		local index = table.find(cacheReference.ButtonActivatedPlatforms, descendant)
		if index ~= nil then table.remove(cacheReference.ButtonActivatedPlatforms, index) end
	end)

	-- Handle Button Activating --

	trove:Connect(communicators.event, function(type: string, ...)
		if type == "update-button-platforms" then
			local targetButton: Button, isPressed: boolean = ...
			if typeof(isPressed) ~= "boolean" then return end
			if not (typeof(targetButton) == "table" and typeof(targetButton.ID) == "string") then return end

			local doNotContinue: boolean = false
			local valuesToChange: { BoolValue } = {}

			local targetButtonHasTimer = hasTimer(targetButton)
			for _, currentButton: Button in cacheReference.Buttons do -- Check for buttons with the same color
				if currentButton.ID == targetButton.ID or currentButton.Color ~= targetButton.Color then continue end -- Same button or button with a different color

				local timerInvolved = targetButtonHasTimer or hasTimer(currentButton)
				local pressed = currentButton.Pressed
				if (timerInvolved and pressed.Value == true) or ((not timerInvolved) and pressed.Value == isPressed) then
					doNotContinue = true
				elseif not timerInvolved then
					table.insert(valuesToChange, pressed)
				end
			end

			if doNotContinue == true then return end
			for _, pressed in valuesToChange do
				pressed.Value = isPressed
			end

			local partsActivated = 0
			for _, platform in cacheReference.ButtonActivatedPlatforms do
				activatePlatform(platform, isPressed, targetButton)
				partsActivated += 1
				if (partsActivated % PART_BUFFER) == 0 then task.wait() end
			end
		end
	end)

	-- Initialize Sequencer Function --
	sequencerManager(scope)
    end
]]
