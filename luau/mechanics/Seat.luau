--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local TRIP_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

type SeatVisualizer = {
	attachment0: Attachment,
	attachment1: Attachment,
	beam: Beam,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Seat"

function mech:init(wth)
	local Seat: utils.Entity<BasePart> = wth:useTag("Seat", utils.t.instanceIsA("BasePart"))
	local Cooldown = wth:useAttribute("Cooldown", Seat, utils.t.numberPositive, 0)
	local JumpOnDismount = wth:useAttribute("JumpOnDismount", Seat, utils.t.boolean, true)
	local Visualize = wth:useAttribute("Visualize", Seat, utils.t.boolean, true)
	local SeatVisualizer: utils.Entity<SeatVisualizer> = utils.world:component()

	local isSeated = false
	local weld: WeldConstraint
	local lastSit = os.clock()

	local querySeat = wth.world:query(Seat, Cooldown, JumpOnDismount):cached()
	local querySeatVisualizers = wth.world:query(Seat, Visualize):cached()

	local function updateSeatVisualizers(_, trove: utils.Trove)
		for entity, seat, visualize in querySeatVisualizers:iter() do
			local seatVisualizer = utils.world:get(entity, SeatVisualizer)

			if visualize then
				local halfSeatHeight = seat.Size.Y / 2

				if seatVisualizer then
					if seatVisualizer.attachment0 then
						seatVisualizer.attachment0.CFrame = CFrame.new(0, halfSeatHeight, 0)
					end

					if seatVisualizer.attachment1 then
						seatVisualizer.attachment1.CFrame = CFrame.new(0, halfSeatHeight + 1, 0)
					end
				else
					local attachment0 = trove:add(Instance.new("Attachment"))
					attachment0.Name = "SeatVisualizerAttachment0"
					attachment0.CFrame = CFrame.new(0, halfSeatHeight, 0)

					local attachment1 = trove:add(Instance.new("Attachment"))
					attachment1.Name = "SeatVisualizerAttachment1"
					attachment1.CFrame = CFrame.new(0, halfSeatHeight + 1, 0)

					local beam = trove:add(Instance.new("Beam"))
					beam.Name = "SeatVisualizerBeam"
					beam.Attachment0 = attachment0
					beam.Attachment1 = attachment1
					beam.FaceCamera = true
					beam.Segments = 1
					beam.Texture = utils.assets.ui.fill
					beam.TextureSpeed = 0
					beam.Width1 = 0
					beam.Transparency = NumberSequence.new(0.5)
					beam.LightInfluence = 0
					beam.Brightness = 1
					beam.Parent = attachment0

					attachment0.Parent = seat
					attachment1.Parent = seat

					utils.world:set(entity, SeatVisualizer, {
						attachment0 = attachment0,
						attachment1 = attachment1,
						beam = beam,
					})
				end
			elseif seatVisualizer then
				if seatVisualizer.beam then
					seatVisualizer.beam:Destroy()
				end

				if seatVisualizer.attachment0 then
					seatVisualizer.attachment0:Destroy()
				end

				if seatVisualizer.attachment1 then
					seatVisualizer.attachment1:Destroy()
				end

				utils.world:remove(entity, SeatVisualizer)
			end
		end
	end

	local function checkSeat(_, trove: utils.Trove)
		if isSeated then
			return
		end

		local humanoid = utils.getMaybeHumanoid()
		local root = utils.getMaybeHumanoidRootPart()
		if not humanoid or not root then
			return
		end

		for entity, seat, cooldown, jumpOnDismount in querySeat:iter() do
			if os.clock() - lastSit < cooldown then
				continue
			end

			for _, toucher in workspace:GetPartsInPart(seat) do
				if utils.checkTouched(toucher, TRIP_PART_TOUCH_CONFIG) then
					lastSit = os.clock()
					isSeated = true

					humanoid.Sit = true
					root.CFrame = seat.CFrame * CFrame.new(0, seat.Size.Y / 2 + 1.5, 0)

					weld = trove:add(Instance.new("WeldConstraint"))
					weld.Part0 = seat
					weld.Part1 = root
					weld.Parent = seat

					local function stopSitting()
						if not isSeated then
							return
						end

						isSeated = false

						if weld then
							weld:Destroy()
						end

						local humanoid = utils.getHumanoid()
						local state = humanoid:GetState()
						-- TODO: this may be different when the player jumps
						if jumpOnDismount then
							if state ~= Enum.HumanoidStateType.Jumping then
								humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
					end

					trove:add(UserInputService.JumpRequest:Once(stopSitting))

					return
				end
			end
		end
	end

	wth:schedule(updateSeatVisualizers, checkSeat)
end

return mech
