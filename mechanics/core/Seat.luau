--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local DISTANCE_FROM_ROOT_TO_GROUND = 3
local OFFSET_CHARACTER_BY = DISTANCE_FROM_ROOT_TO_GROUND / 2

type SeatAttributes = {
	Enabled: boolean,
	Cooldown: boolean,
	JumpOnDismount: boolean,
	Visualize: boolean,
}

local function init(wth: utils.WTH)
	local Seat = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Seat",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Enabled = true,
			Cooldown = 0,
			JumpOnDismount = true,
			Visualize = true,
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			Cooldown = utils.t.numberPositive,
			JumpOnDismount = utils.t.boolean,
			Visualize = utils.t.boolean,
		},
	} :: utils.Mechanic<BasePart, SeatAttributes>

	local seated = false

	function Seat:loaded(trove, instance)
		local debounce = false
		trove:add(instance.Touched:Connect(function(toucher)
			local canBeSeated = not seated
				and not debounce
				and utils.isFromMaybeLocalCharacter(toucher)
				and utils.isLocalCharacterAlive()

			if canBeSeated then
				local root = assert(utils.getMaybeLocalHumanoidRootPart(), "can be assumed")
				local humanoid = assert(utils.getMaybeLocalHumanoid(), "can be assumed")

				debounce = true
				seated = true

				root.CFrame = instance.CFrame + Vector3.new(0, instance.Size.Y / 2 + OFFSET_CHARACTER_BY, 0)
				humanoid.Sit = true
				local weldTrove = trove:extend()
				utils.weld(weldTrove, instance, root)

				weldTrove:connect(UserInputService.JumpRequest, function()
					weldTrove:clean()
				end)

				weldTrove:connect(humanoid.Died, function()
					weldTrove:clean()
				end)

				local function dismount()
					seated = false
					local humanoid = utils.getMaybeLocalHumanoid()
					if self:attribute(instance, "JumpOnDismount") and humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end

				weldTrove:add(dismount)
				task.delay(self:attribute(instance, "Cooldown"), function()
					debounce = false
				end)
			end
		end))
	end

	wth.registerMechanic(Seat)
end

return init
