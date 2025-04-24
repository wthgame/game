--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit) end

return self
