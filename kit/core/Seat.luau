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

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Seat = kit:tag("Seat", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	local seated = false

	Seat:onLoaded(function(trove, instance)
		local debounce = false
		trove:add(instance.Touched:Connect(function(toucher)
			local canBeSeated = utils.Active(instance)
				and not seated
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
					if JumpOnDismount(instance) and humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end

				weldTrove:add(dismount)
				task.delay(Cooldown(instance), function()
					debounce = false
				end)
			end
		end))
	end)
end

return self
