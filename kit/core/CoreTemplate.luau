--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit) end

return self
