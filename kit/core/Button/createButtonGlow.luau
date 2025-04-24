--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local ButtonAttributes = require("./ButtonAttributes")
local PressTime = ButtonAttributes.PressTime
local PressEasingStyle = ButtonAttributes.PressEasingStyle
local PressEasingDirection = ButtonAttributes.PressEasingDirection

local function createButtonGlow(outerTrove: utils.Trove, btn: BasePart)
	local trove = outerTrove:extend()
	local instanceTrove = outerTrove:extend()

	-- don't add to trove yet, we will when we finish animations
	local glow = instanceTrove:clone(btn)
	glow.Anchored = false
	glow.CanCollide = false
	glow.CanTouch = false
	glow.CanQuery = false
	glow.Material = Enum.Material.Neon
	glow.Name = "ButtonGlow"
	glow.Size *= Vector3.new(1.005, 1.005, 1.005)
	glow.Massless = true
	glow.Transparency = 1

	local alignPosition = instanceTrove:add(Instance.new("AlignPosition"))
	alignPosition.Responsiveness = 200
	local alignOrientation = instanceTrove:add(Instance.new("AlignOrientation"))
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

	utils.tweenMaybeInstant(glow, { Transparency = 0.5 }, {
		time = PressTime(btn),
		easingStyle = PressEasingStyle(btn),
		easingDirection = PressEasingDirection(btn),
	})

	trove:add(function()
		local time = PressTime(btn)
		utils.tweenMaybeInstant(glow, { Transparency = 1 }, {
			time = time,
			easingStyle = PressEasingStyle(btn),
			easingDirection = PressEasingDirection(btn),
		})
		task.delay(time, function()
			instanceTrove:clean()
		end)
	end)
end

return createButtonGlow
