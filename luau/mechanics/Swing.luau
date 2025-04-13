--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local SWING_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

type SwingInstance = Instance & {
	Rope: BasePart,
	Top: BasePart,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Swing"

function mech:init(wth)
	local Swing: utils.Entity<SwingInstance> = wth:useTag(
		"Swing",
		utils.t.children({
			Rope = utils.t.instanceIsA("BasePart"),
			Top = utils.t.instanceIsA("BasePart"),
		})
	)

	local Cooldown = wth:useAttribute("Cooldown", Swing, utils.t.numberPositive, 0)
	local Mode = wth:useAttribute("Mode", Swing, utils.t.literal("Rope", "Rod", "Spring"), "Rope")
	local RopeLength = wth:useAttribute("RopeLength", Swing, utils.t.numberPositive, 0)
	local SpringStiffness = wth:useAttribute("SpringStiffness", Swing, utils.t.numberPositive, 0)

	local isSwinging = false

	local querySwings = wth.world:query(Swing, Cooldown, RopeLength, Mode, SpringStiffness):cached()

	local function checkSwings(_, trove: utils.Trove)
		if isSwinging then
			return
		end

		for entity, swing, cooldown, ropeLength, mode, springStiffness in querySwings:iter() do
			local rope = swing.Rope
			local top = swing.Top

			for _, toucher in workspace:GetPartsInPart(rope) do
				if utils.checkTouched(toucher, SWING_TOUCH_CONFIG) then
					local originalRopeTransparency = rope.Transparency
					isSwinging = true

					local swingTrove = trove:extend()

					local swingBar = swingTrove:add(Instance.new("Part"))
					swingBar.Parent = swing
					swingBar.Size = Vector3.new(3, 0.4, 0.4)
					swingBar.TopSurface = Enum.SurfaceType.Smooth
					swingBar.BottomSurface = Enum.SurfaceType.Smooth
					swingBar.CanCollide = false
					swingBar.CFrame = toucher.Parent.HumanoidRootPart.CFrame * CFrame.new(0, 2.6, 0)
					swingBar.CustomPhysicalProperties = PhysicalProperties.new(10, 0, 0)
					swingBar.Color = rope.Color

					local attachmentTop = swingTrove:add(Instance.new("Attachment"))
					attachmentTop.Parent = top

					local attachmentPoint1 = swingTrove:add(Instance.new("Attachment"))
					attachmentPoint1.Parent = top

					local attachmentPoint2 = swingTrove:add(Instance.new("Attachment"))
					attachmentPoint2.Parent = swingBar

					if mode == "Rope" then
						local ropeConstraint = swingTrove:add(Instance.new("RopeConstraint"))
						ropeConstraint.Length = ropeLength
						ropeConstraint.Visible = true
						ropeConstraint.Color = rope.BrickColor
						ropeConstraint.Attachment0 = attachmentPoint1
						ropeConstraint.Attachment1 = attachmentPoint2
						ropeConstraint.Parent = top
					elseif mode == "Rod" then
						local rodConstraint = swingTrove:add(Instance.new("RodConstraint"))
						rodConstraint.Length = ropeLength
						rodConstraint.Visible = true
						rodConstraint.Color = rope.BrickColor
						rodConstraint.Attachment0 = attachmentPoint1
						rodConstraint.Attachment1 = attachmentPoint2
						rodConstraint.Parent = top
					elseif mode == "Spring" then
						local springConstraint = swingTrove:add(Instance.new("SpringConstraint"))
						springConstraint.Visible = true
						springConstraint.Color = rope.BrickColor
						springConstraint.Attachment0 = attachmentPoint1
						springConstraint.Attachment1 = attachmentPoint2
						springConstraint.FreeLength = ropeLength
						springConstraint.Stiffness = springStiffness
						springConstraint.Parent = top
					end

					local weldConstraint = swingTrove:add(Instance.new("WeldConstraint"))
					weldConstraint.Part0 = toucher.Parent.HumanoidRootPart
					weldConstraint.Part1 = swingBar
					weldConstraint.Parent = swingBar

					rope.Transparency = 1

					local function dismount()
						local humanoid = utils.getMaybeHumanoid()
						if humanoid then
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end

						swingTrove:clean()

						-- FIXME: this may be different once the player dismounts
						if cooldown == 0 then
							isSwinging = false
							rope.Transparency = originalRopeTransparency
							return
						end

						task.wait(cooldown)

						isSwinging = false
						rope.Transparency = originalRopeTransparency
					end

					trove:add(UserInputService.JumpRequest:Once(dismount))

					return
				end
			end
		end
	end

	wth:schedule(checkSwings)
end

return mech
