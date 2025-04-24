--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Tripper = kit:tag("Tripper", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Tripper:onLoaded(function(trove, instance)
		local debounce = false
		trove:add(instance.Touched:Connect(function(toucher)
			if debounce then
				return
			end

			if utils.Active(instance) and utils.isFromMaybeLocalCharacter(toucher) then
				local humanoid = assert(utils.getMaybeLocalHumanoid(), "can be assumed it exists")
				humanoid.Sit = true

				debounce = true
				task.delay(Cooldown(instance), function()
					debounce = false
				end)
			end
		end))
	end)
end

return self
