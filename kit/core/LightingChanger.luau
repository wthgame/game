--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function changeLighting(_: std.Trove, changer: Instance)
	-- TODO
end

function self:run(kit: std.Kit)
	local LightingChanger = kit:tag("LightingChanger")
	LightingChanger:onActivated(changeLighting)
end

return self
