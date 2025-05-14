--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude
local NodeTypes = require(script:WaitForChild("NodeTypes"))
local NodeUtils = require(script:WaitForChild("NodeUtils"))

local NodeType: utils.InstanceAttribute<string> = prelude.attribute("NodeType", prelude.t.keyOf(NodeTypes)) :: any

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Node = kit:tag("Node")

	local nodeVariables: utils.Map<string, unknown> = {}

	Node:onLoaded(function(trove, node) end)
end

return self
