--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local ButtonAttributes = require("./ButtonAttributes")
local PressTime = ButtonAttributes.PressTime
local PressEasingStyle = ButtonAttributes.PressEasingStyle
local PressEasingDirection = ButtonAttributes.PressEasingDirection

local function glowButton(outerTrove: utils.Trove, btn: BasePart, flash: boolean?)
	local trove = outerTrove:extend()
	local instanceTrove = utils.Trove.new()

	-- don't add to trove yet, we will when we finish animations
	local glow = instanceTrove:clone(btn)
	glow.Anchored = false
	glow.CanCollide = false
	glow.CanTouch = false
	glow.CanQuery = false
	glow.Material = Enum.Material.Neon
	glow.Name = "ButtonGlow"
	glow.Size *= Vector3.new(1.008, 1.008, 1.008)
	glow.Massless = true
	glow.Transparency = 1

	local alignPosition = instanceTrove:add(Instance.new("AlignPosition"))
	alignPosition.MaxForce = math.huge
	alignPosition.Responsiveness = 200
	local alignOrientation = instanceTrove:add(Instance.new("AlignOrientation"))
	alignOrientation.MaxAngularVelocity = math.huge
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 200

	local attachment0, attachment1 = utils.populateConstraintAttachments(alignPosition)
	alignOrientation.Attachment0 = instanceTrove:add(attachment0)
	alignOrientation.Attachment1 = instanceTrove:add(attachment1)

	-- utils.weld(trove, btn, glow)

	attachment0.Parent = glow
	attachment1.Parent = btn
	alignPosition.Parent = glow
	alignOrientation.Parent = glow
	glow.Parent = btn

	if flash then
		local time = PressTime(btn)
		utils.tweenMaybeInstant(glow, { Transparency = 0.5 }, {
			time = time / 2,
			easingStyle = PressEasingStyle(btn),
			easingDirection = PressEasingDirection(btn),
			reverse = true,
		})
		task.delay(time, function()
			instanceTrove:clean()
		end)
	else
		utils.tweenMaybeInstant(glow, { Transparency = 0.5 }, utils.tweenConfigFromAttributes(btn, "Press"))
		trove:add(function()
			local time = PressTime(btn)
			utils.tweenMaybeInstant(glow, { Transparency = 1 }, utils.tweenConfigFromAttributes(btn, "Press"))
			task.delay(time, function()
				instanceTrove:clean()
			end)
		end)
	end
end

return glowButton
