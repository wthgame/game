--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TripperAttributes = {
	Cooldown: number,
}

local function init(wth: utils.WTH)
	local Tripper = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Tripper",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Cooldown = 0,
		},
		attributeChecks = {
			Cooldown = utils.t.numberPositive,
		},
	} :: utils.Mechanic<BasePart, TripperAttributes>

	function Tripper:loaded(trove, instance)
		local debounce = false
		trove:add(instance.Touched:Connect(function(toucher)
			if debounce then
				return
			end

			if utils.isFromMaybeLocalCharacter(toucher) then
				local humanoid = assert(utils.getMaybeLocalHumanoid(), "can be assumed it exists")
				humanoid.Sit = true

				debounce = true
				task.delay(self:attribute(instance, "Cooldown"), function()
					debounce = false
				end)
			end
		end))
	end

	wth.registerMechanic(Tripper)
end

return init
