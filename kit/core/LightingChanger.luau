--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local self = {} :: utils.KitScript
self.type = "KitScript"

local function changeLighting(changer: Instance)
	-- TODO
end

function self:run(kit: utils.Kit)
	local LightingChanger = kit:tag("LightingChanger", utils.isBasePart)

	LightingChanger:onLoaded(function(trove, lc)
		utils.connectActivation(trove, lc, changeLighting)
	end)
end

return self
