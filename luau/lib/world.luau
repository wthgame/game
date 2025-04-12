--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ecs = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHShared"):WaitForChild("ecs"))
local jecs = require("./packages/jecs")

local world = ecs.world :: jecs.World

return world
