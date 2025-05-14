--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

export type NodeType = {}

local NodeUtils = {}

table.freeze(NodeUtils)
return NodeUtils
