--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local DISTANCE_FROM_ROOT_TO_GROUND = 3
local OFFSET_CHARACTER_BY = DISTANCE_FROM_ROOT_TO_GROUND / 2

local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
local JumpOnDismount = prelude.attribute("JumpOnDismount", prelude.isBoolean, true)
-- local Visualize = prelude.attribute("Visualize", prelude.isBoolean, true)

local seated = false
local debounced: utils.Set<BasePart> = {}

local function seatPlayer(trove: utils.Trove, seat: BasePart, activationTrove: utils.Trove)
	local canBeSeated = prelude.Active(seat)
		and not seated
		and not debounced[seat]
		and utils.character.isCharacterAlive()

	if canBeSeated then
		local root = assert(prelude.getMaybeHumanoidRootPart(), "can be assumed")
		local humanoid = assert(prelude.getMaybeHumanoid(), "can be assumed")

		debounced[seat] = true
		seated = true
		activationTrove:clean()

		root.CFrame = seat.CFrame + Vector3.new(0, seat.Size.Y / 2 + OFFSET_CHARACTER_BY, 0)
		humanoid.Sit = true

		local weldTrove = trove:extend()
		weldTrove:attachToInstance(root)
		utils.physics.weld(weldTrove, seat, root)

		weldTrove:connect(UserInputService.JumpRequest, function()
			weldTrove:clean()
		end)

		weldTrove:connect(humanoid.Died, function()
			weldTrove:clean()
		end)

		local function dismount()
			seated = false
			local humanoid = prelude.getMaybeHumanoid()
			if JumpOnDismount(seat) and humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			prelude.connectActivation(trove, seat, seatPlayer)
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
	local Seat = kit:tag("Seat", prelude.isBasePart)
	Seat:onActivated(seatPlayer)
end

return self
