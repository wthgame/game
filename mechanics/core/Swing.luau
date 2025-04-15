--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type SwingInstance = Instance & {
	Constraint: Constraint,
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
			Constraint = utils.t.instanceIsA("Constraint"),
			Rope = utils.t.instanceIsA("BasePart"),
			Top = utils.t.instanceIsA("BasePart"),
		})
	)

	local Cooldown = wth:useAttribute("Cooldown", Swing, utils.t.numberPositive, 0)

	local isSwinging = false
	local lastSwing = os.clock()

	local querySwings = wth.world:query(Swing, Cooldown):cached()

	local function checkSwings(_, trove: utils.Trove)
		local root = utils.getMaybeHumanoidRootPart()
		if not root then
			return
		end

		if isSwinging then
			return
		end

		for entity, swing, cooldown in querySwings:iter() do
			if os.clock() - lastSwing < cooldown then
				continue
			end

			local rope = swing.Rope
			local top = swing.Top

			if utils.isLocalPlayerCharacterTouchingPart(rope) then
				isSwinging = true
				lastSwing = os.clock()

				local originalRopeTransparency = rope.Transparency

				local swingTrove = trove:extend()

				local swingBar = swingTrove:add(Instance.new("Part"))
				swingBar.Parent = swing
				swingBar.Size = Vector3.new(3, 0.4, 0.4)
				swingBar.TopSurface = Enum.SurfaceType.Smooth
				swingBar.BottomSurface = Enum.SurfaceType.Smooth
				swingBar.CanCollide = false
				swingBar.CFrame = root.CFrame * CFrame.new(0, 2.6, 0)
				swingBar.CustomPhysicalProperties = PhysicalProperties.new(10, 0, 0)
				swingBar.Color = rope.Color

				local attachmentTop = swingTrove:add(Instance.new("Attachment"))
				attachmentTop.Parent = top

				local attachmentPoint1 = swingTrove:add(Instance.new("Attachment"))
				attachmentPoint1.Parent = top

				local attachmentPoint2 = swingTrove:add(Instance.new("Attachment"))
				attachmentPoint2.Parent = swingBar

				local constraint = swingTrove:add(swing.Constraint:Clone())
				constraint.Attachment0 = attachmentTop
				constraint.Attachment1 = attachmentPoint2
				constraint.Parent = top

				local weldConstraint = swingTrove:add(Instance.new("WeldConstraint"))
				weldConstraint.Part0 = root
				weldConstraint.Part1 = swingBar
				weldConstraint.Parent = swingBar

				rope.Transparency = 1

				local function dismount()
					print("DISMOUNTING")
					isSwinging = false
					swingTrove:clean()
					rope.Transparency = originalRopeTransparency

					local humanoid = utils.getMaybeHumanoid()
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end

					return
					-- end

					-- task.wait(cooldown)

					-- rope.Transparency = originalRopeTransparency
				end

				trove:add(UserInputService.JumpRequest:Once(dismount))

				return
			end
		end
	end

	wth:schedule(checkSwings)
end

return mech
