--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude
local Dismounter = require("./Dismounter")

local DISTANCE_FROM_ROOT_TO_GROUND = 3
local OFFSET_CHARACTER_BY = DISTANCE_FROM_ROOT_TO_GROUND / 2

local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
local JumpOnDismount = prelude.attribute("JumpOnDismount", prelude.isBoolean, true)
-- local Visualize = prelude.attribute("Visualize", prelude.isBoolean, true)

local seated = false
local debounced: std.Set<BasePart> = {}
local logger = prelude.createLogger("Seat")

local function seatPlayer(trove: std.Trove, seat: BasePart)
	local canBeSeated = prelude.Enabled(seat)
		and not seated
		and not debounced[seat]
		and std.character.isCharacterAlive()

	if canBeSeated then
		logger:info("Seating")
		local root = assert(prelude.getMaybeHumanoidRootPart(), "can be assumed")
		local humanoid = assert(prelude.getMaybeHumanoid(), "can be assumed")

		debounced[seat] = true
		seated = true

		local wasActivatable = prelude.Activatable(seat)
		if wasActivatable == nil then
			wasActivatable = true
		end
		prelude.Activatable:set(seat, false)

		root.CFrame = seat.CFrame + Vector3.new(0, seat.Size.Y / 2 + OFFSET_CHARACTER_BY, 0)
		humanoid.Sit = true

		local weldTrove = trove:extend()
		weldTrove:attachToInstance(root)
		std.physics.weld(weldTrove, seat, root)

		weldTrove:connect(UserInputService.JumpRequest, function()
			weldTrove:clean()
		end)

		weldTrove:connect(humanoid.Died, function()
			weldTrove:clean()
		end)

		weldTrove:connect(Dismounter.onDismount :: any, function(targets)
			if targets.Seat then
				weldTrove:clean()
			end
		end)

		local function dismount()
			seated = false
			local humanoid = prelude.getMaybeHumanoid()
			if JumpOnDismount(seat) and humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			prelude.Activatable:set(seat, wasActivatable)
		end

		weldTrove:add(dismount)
		task.delay(Cooldown(seat), function()
			debounced[seat] = nil
		end)
	end
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Seat = kit:tag("Seat", prelude.isBasePart)
	Seat:onActivated(seatPlayer)
end

return self
