--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local self = {} :: std.KitScript
self.type = "KitScript"

function self:run(kit: std.Kit) end

return self
