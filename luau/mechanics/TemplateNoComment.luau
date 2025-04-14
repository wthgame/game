--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "TemplateNoComment"

function mech:init(wth) end

return mech
