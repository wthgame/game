--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local function glowButton(outerTrove: std.Trove, btn: BasePart, flash: boolean?)
	local trove = outerTrove:extend()
	local instanceTrove = std.packages.createTrove()

	-- don't add to trove yet, we will when we finish animations
	local glow = instanceTrove:clone(btn)
	glow.Anchored = false
	glow.CanCollide = false
	glow.CanTouch = false
	glow.CanQuery = false
	glow.Material = Enum.Material.Neon
	glow.Name = "ButtonGlow"
	glow.Size *= Vector3.new(1.01, 1.01, 1.01)
	glow.Massless = true
	glow.Transparency = 1

	local alignPosition = instanceTrove:add(Instance.new("AlignPosition"))
	alignPosition.MaxForce = math.huge
	alignPosition.Responsiveness = 200
	local alignOrientation = instanceTrove:add(Instance.new("AlignOrientation"))
	alignOrientation.MaxAngularVelocity = math.huge
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 200

	local attachment0, attachment1 = std.physics.populateConstraintAttachments(alignPosition)
	alignOrientation.Attachment0 = instanceTrove:add(attachment0)
	alignOrientation.Attachment1 = instanceTrove:add(attachment1)

	-- std.weld(trove, btn, glow)

	attachment0.Parent = glow
	attachment1.Parent = btn
	alignPosition.Parent = glow
	alignOrientation.Parent = glow
	glow.Parent = btn

	local config = prelude.tweenConfigFromAttributes(btn, "Press")

	if flash then
		local time = config.time or 1
		prelude.tweenMaybeInstant(glow, { Transparency = 0.5 }, {
			time = time / 2,
			easingStyle = config.easingStyle,
			easingDirection = config.easingDirection,
			reverse = true,
		})
		task.delay(time, function()
			instanceTrove:clean()
		end)
	else
		prelude.tweenMaybeInstant(glow, { Transparency = 0.5 }, prelude.tweenConfigFromAttributes(btn, "Press"))
		trove:add(function()
			local time = config.time or 1
			prelude.tweenMaybeInstant(glow, { Transparency = 1 }, prelude.tweenConfigFromAttributes(btn, "Press"))
			task.delay(time, function()
				instanceTrove:clean()
			end)
		end)
	end
end

return glowButton
