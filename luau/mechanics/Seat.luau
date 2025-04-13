--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local TRIP_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "Seat"

function mech:init(wth)
	local Seat: utils.Entity<BasePart> = wth:useTag("Seat", utils.t.instanceIsA("BasePart"))
	local Cooldown = wth:useAttribute("Cooldown", Seat, utils.t.numberPositive, 0)

	local isSeated = false
	local weld: WeldConstraint
	local lastSit = os.clock()

	local function stopSitting()
		if not isSeated then
			return
		end

		isSeated = false

		if weld then
			weld:Destroy()
		end

		local humanoid = utils.getHumanoid()
		if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	local querySeat = wth.world:query(Seat, Cooldown):cached()

	local function checkSeat(_, trove: utils.Trove)
		if isSeated then
			return
		end

		local humanoid = utils.getMaybeHumanoid()
		local root = utils.getMaybeHumanoidRootPart()
		if not humanoid or not root then
			return
		end

		for entity, seat, cooldown in querySeat:iter() do
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

					trove:add(UserInputService.JumpRequest:Once(stopSitting))

					return
				end
			end
		end
	end

	wth:schedule(checkSeat)
end

return mech
