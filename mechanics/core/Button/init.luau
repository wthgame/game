--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- NOTE: If you're looking to fork this Mechanic, consider changing all Buttons
-- in your tower to use the forked Mechanic tags.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local colorUpdates = require(script:WaitForChild("colorUpdates"))
local getPartColor = require(script:WaitForChild("getPartColor"))
local getTransparency = require(script:WaitForChild("getTransparency"))
local updateColor, spawnOnceColorUpdated = colorUpdates.updateColor, colorUpdates.spawnOnceColorUpdated
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local PRESS_TWEEN_CONFIG: utils.TweenConfig = { time = 0.3, easingStyle = Enum.EasingStyle.Quart }
local VISIBILITY_TWEEN_CONFIG: utils.TweenConfig = { time = 0.3, easingStyle = Enum.EasingStyle.Quart }

local TOGGLEABLE_PROPERTIES: utils.Map<string, utils.Set<string>> = {
	BasePart = { CanCollide = true },
	Fire = { Enabled = true },
	Sparkles = { Enabled = true },
	Smoke = { Enabled = true },
	Trail = { Enabled = true },
	UIStroke = { Enabled = true },
	UIGradient = { Enabled = true },
}

local TWEENABLE_VISIBILITY_PROPERTIES: utils.Map<string, utils.Set<string>> = {
	BasePart = { Transparency = true },
	Decal = { Transparency = true },
	Texture = { Transparency = true },
	SelectionBox = { Transparency = true },
	SelectionSphere = { Transparency = true },
	Frame = { BackgroundTransparency = true },
	CanvasGroup = { GroupTransparency = true },
	TextLabel = { TextTransparency = true },
	TextBox = { TextTransparency = true },
	TextButton = { TextTransparency = true },
	ImageLabel = { ImageTransparency = true },
	ImageButton = { ImageTransparency = true },
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Button"

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

	local ButtonEnabled: utils.Entity<Instance> = wth:useTag("ButtonEnabled")
	local Updated: utils.Entity = wth.world:component()
	local Color = wth:useAttribute("Color", ButtonEnabled, utils.t.optional(utils.t.Color3), nil)
	local Invert = wth:useAttribute("Invert", ButtonEnabled, utils.t.boolean, false)
	-- stylua: ignore
	local SetTransparency = wth:useAttribute("SetTransparency", ButtonEnabled, utils.t.optional(utils.t.numberPositive), nil)
	local SetInvisible = wth:useAttribute("SetInvisible", ButtonEnabled, utils.t.boolean, false)

	local enabledColors: utils.Set<Color3> = {}
	local function isColorEnabled(color: Color3): boolean
		for active in enabledColors do
			if active == color then
				return true
			end
		end
		return false
	end

	local function disable(
		btn: utils.Entity,
		part: BasePart,
		color: Color3,
		originalCFrame: CFrame,
		originalMaterial: Enum.Material
	)
		wth.world:remove(btn, Activated)
		enabledColors[color] = nil
		utils.tween(part, { CFrame = originalCFrame }, PRESS_TWEEN_CONFIG)
		part.Material = originalMaterial
		updateColor(color)
	end

	local function enable(btn: utils.Entity, part: BasePart, duration: number, offset: Vector3 | CFrame)
		wth.world:add(btn, Activated)
		utils.playSoundFromGameAssets("button", part)

		local originalCFrame = part.CFrame
		local originalMaterial = part.Material

		local buttonActivatedCFrame = part.CFrame
		if typeof(offset) == "Vector3" then
			buttonActivatedCFrame *= CFrame.new(offset)
		else
			buttonActivatedCFrame *= offset
		end

		part.Material = Enum.Material.Neon
		utils.tween(part, { CFrame = buttonActivatedCFrame }, PRESS_TWEEN_CONFIG)

		local color = getPartColor(part)
		enabledColors[color] = true
		updateColor(color)

		local isFinite = duration ~= 0 and duration < math.huge
		if isFinite then
			task.delay(duration, disable, btn, part, color, originalCFrame, originalMaterial)
		end
	end

	local buttons = wth.world:query(Button, Cooldown, Duration, ActiveOffset):without(Activated):cached()
	local function enableButtons()
		for btn, part, cooldown, duration, offset in buttons:iter() do
			if not utils.isCharacterTouchingPart(part) then
				continue
			end

			enable(btn, part, duration, offset)
		end
	end

	-- stylua: ignore
	local buttonEnableds = wth.world:query(ButtonEnabled, Color, Invert, SetInvisible, SetTransparency):without(Updated):cached()

	local function buttonsEnable()
		for be, instance, color, invert, setInvisible, setTransparency in buttonEnableds:iter() do
			local resolvedColor: Color3? = color
			if not resolvedColor then
				if instance:IsA("BasePart") then
					resolvedColor = instance.Color
				end
			end

			if not resolvedColor then
				continue
			end

			local roundedColor = utils.roundColor(resolvedColor)

			local enabled = isColorEnabled(roundedColor)
			if invert then
				enabled = not enabled
			end

			for class, toggleable in TOGGLEABLE_PROPERTIES do
				if instance:IsA(class) then
					for property in toggleable do
						(instance :: any)[property] = enabled
					end
					break
				end
			end

			for class, tweenable in TWEENABLE_VISIBILITY_PROPERTIES do
				if instance:IsA(class) then
					local propertyTable = {}
					for property in tweenable do
						propertyTable[property] = getTransparency(enabled, setInvisible, setTransparency)
					end
					utils.tween(instance, propertyTable, VISIBILITY_TWEEN_CONFIG)
					break
				end
			end

			wth.world:add(be, Updated)
			spawnOnceColorUpdated(roundedColor, function()
				wth.world:remove(be, Updated)
			end)
		end
	end

	wth:schedule(enableButtons, buttonsEnable)
end

return mech
