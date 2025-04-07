--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

local self = {} :: utils.Mechanic<{}, BasePart>
self.type = "Mechanic"
self.name = "MoltenLava"

self.attributes = {}
self.defaultAttributes = {}

self.instanceCheck = utils.t.instanceIsA("BasePart")

function self:mechanize(ctx: utils.MechanizeContext<{}, BasePart>) end

return self
