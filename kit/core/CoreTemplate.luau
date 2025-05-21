--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local CoreTemplate = {}
type Self = typeof(CoreTemplate)
CoreTemplate.implements = { KitScript = true }

function CoreTemplate.run(self: Self, kit: std.Kit) end

return CoreTemplate
