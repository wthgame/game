--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local DISTANCE_FROM_ROOT_TO_GROUND = 3
local OFFSET_CHARACTER_BY = DISTANCE_FROM_ROOT_TO_GROUND / 2

local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
local JumpOnDismount = utils.attribute("JumpOnDismount", utils.t.boolean, true)
-- local Visualize = utils.attribute("Visualize", utils.t.boolean, true)

local seated = false
local debounced: utils.Set<BasePart> = {}

local function seatPlayer(trove: utils.Trove, seat: BasePart, activationTrove: utils.Trove)
	print("SEATING PLAYER...")
	local canBeSeated = utils.Active(seat) and not seated and not debounced[seat] and utils.isCharacterAlive()

	if canBeSeated then
		local root = assert(utils.getMaybeHumanoidRootPart(), "can be assumed")
		local humanoid = assert(utils.getMaybeHumanoid(), "can be assumed")

		debounced[seat] = true
		seated = true
		activationTrove:clean()

		root.CFrame = seat.CFrame + Vector3.new(0, seat.Size.Y / 2 + OFFSET_CHARACTER_BY, 0)
		humanoid.Sit = true

		local weldTrove = trove:extend()
		weldTrove:attachToInstance(root)
		utils.weld(weldTrove, seat, root)

		weldTrove:connect(UserInputService.JumpRequest, function()
			weldTrove:clean()
		end)

		weldTrove:connect(humanoid.Died, function()
			weldTrove:clean()
		end)

		local function dismount()
			seated = false
			local humanoid = utils.getMaybeHumanoid()
			if JumpOnDismount(seat) and humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			utils.connectActivation(trove, seat, seatPlayer)
		end

		weldTrove:add(dismount)
		task.delay(Cooldown(seat), function()
			debounced[seat] = nil
		end)
	end
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Seat = kit:tag("Seat", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Seat:onLoaded(function(trove, instance)
		utils.connectActivation(trove, instance, seatPlayer)
	end)
end

return self
