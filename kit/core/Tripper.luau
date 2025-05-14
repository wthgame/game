--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)

local debounced: utils.Set<BasePart> = {}

local self = {} :: utils.KitScript
self.type = "KitScript"

local function tripPlayer(trove: utils.Trove, tripper: BasePart)
	if not debounced[tripper] then
		local humanoid = assert(prelude.getMaybeHumanoid(), "can be assumed it exists")
		humanoid.Sit = true
		debounced[tripper] = true
		task.delay(Cooldown(tripper), function()
			debounced[tripper] = nil
		end)
	end
end

function self:run(kit: utils.Kit)
	local Tripper = kit:tag("Tripper", prelude.isBasePart)
	Tripper:onActivated(tripPlayer)
end

return self
