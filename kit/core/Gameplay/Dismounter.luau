--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local onDismount: std.LemonSignal<Instance> = std.packages.createLemonSignal()

local self = {} :: std.KitScript<{
	onDismount: typeof(onDismount),
}>
self.type = "KitScript"
self.onDismount = onDismount

function self:run(kit: std.Kit) end

return self
