--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit) end

return self
