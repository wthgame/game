--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local self = {} :: utils.KitScript
self.type = "KitScript"

local function changeLighting(_: utils.Trove, changer: Instance)
	-- TODO
end

function self:run(kit: utils.Kit)
	local LightingChanger = kit:tag("LightingChanger")
	LightingChanger:onActivated(changeLighting)
end

return self
