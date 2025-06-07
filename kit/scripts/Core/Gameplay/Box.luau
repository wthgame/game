--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local logger = prelude.createLogger("Box")
local idToBox: std.MapSet<string, BasePart> = std.collections.MapSet()

--- @class Box
--- @tag KitObject
---
--- TBA
local Box = {}
type Self = typeof(Box)
Box.implements = { KitScript = true }

--- @prop idToBox std.MapSet<string, BasePart>
--- @within Box
---
--- TBA
Box.idToBox = idToBox

--- @prop BoxId std.Attribute<string?>
--- @within Box
--- @tag Attribute
---
--- TBA
Box.BoxId = prelude.Attribute("BoxId", prelude.isString)

--- @prop BoxSpawnBehavior std.Attribute<string?>
--- @within Box
--- @tag Attribute
---
--- TBA
Box.BoxSpawnBehavior = prelude.Attribute("BoxSpawnBehavior", prelude.isString)

--- @within Box
---
--- TBA
function Box.spawnBox(self: Self, outerTrove: std.Trove, box: BasePart)
	logger:trace("Spawning box", box:GetFullName())
	box.Parent = workspace
	outerTrove:add(function()
		box.Parent = nil
	end)
end

--- @within Box
---
--- TBA
function Box.spawnBoxesWithId(self: Self, trove: std.Trove, id: string)
	logger:trace("Spawning boxes with id", id)
	for box in idToBox:get(id) do
		self:spawnBox(trove, box)
	end
end

local function onBoxLoaded(trove: std.Trove, box: BasePart)
	logger:debug(box:GetFullName())
	local id = Box.BoxId:assert(box) :: string
	idToBox:add(id, box)
	box.Parent = nil
	trove:add(function()
		idToBox:remove(id, box)
	end)
end

function Box.run(self: Self, kit: std.Kit)
	kit:tag("Box", prelude.isBasePart):onLoaded(onBoxLoaded)
end

return Box
