--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "CoreTemplate"

function mech:init(wth) end

return mech
