--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude
local NodeTypes = require(script:WaitForChild("NodeTypes"))
local NodeUtils = require(script:WaitForChild("NodeUtils"))

local NodeType: std.Attribute<string> = prelude.attribute("NodeType", prelude.t.keyOf(NodeTypes)) :: any

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Node = kit:tag("Node")

	local nodeVariables: std.Map<string, unknown> = {}

	Node:onLoaded(function(trove, node) end)
end

return self
