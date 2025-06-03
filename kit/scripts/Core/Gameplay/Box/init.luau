--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoxTypes = require(script:WaitForChild("BoxTypes"))
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

export type BoxSpawnBehavior = BoxTypes.BoxSpawnBehavior

local logger = prelude.createLogger("Box")
local implementedBehaviors: std.Map<string, BoxSpawnBehavior> = {}
local defaultSpawnBehaviors = script:WaitForChild("DefaultBoxSpawnBehaviors")
local hasImplementedDefaultSpawnBehaviors = false
local idToBox: std.MapSet<string, BasePart> = std.collections.MapSet()

--- @class Box
--- @tag KitObject
---
--- TBA
local Box = {}
type Self = typeof(Box)
Box.implements = { KitScript = true }

--- @function isBoxSpawnBehavior
--- @within Box
---
--- TBA
---
--- @param x unknown -- TBA
--- @return boolean -- TBA
--- @return string? -- TBA
Box.isBoxSpawnBehavior = BoxTypes.isBoxSpawnBehavior

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

function Box.implementSpawnBehavior(self: Self, behavior: BoxSpawnBehavior)
	logger:assert(self.isBoxSpawnBehavior(behavior))
	local existing = implementedBehaviors[behavior.name]
	logger:assert(not existing, `Already implemented BoxSpawnBehavior named "{behavior.name}"`)
	implementedBehaviors[behavior.name] = behavior
end

--- @within Box
---
--- TBA
function Box.implementSpawnBehaviorForBox(self: Self, trove: std.Trove, box: BasePart)
	local behavior = implementedBehaviors[self.BoxSpawnBehavior(box) :: any]
	if behavior then
		if behavior.predicate and not behavior.predicate(box) then
			return
		end
		logger:debug("Implementing", behavior.name, "for", box:GetFullName())
		behavior:spawn(trove, box)
	end
end

--- @within Box
---
--- TBA
function Box.spawnBox(self: Self, outerTrove: std.Trove, box: BasePart)
	logger:trace("Spawning box", box:GetFullName())
	local trove = outerTrove:extend()
	local cloned = trove:clone(box)
	self:implementSpawnBehaviorForBox(trove, cloned)
	cloned.Parent = workspace
	trove:attachToInstance(cloned)
	return cloned
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
	if not hasImplementedDefaultSpawnBehaviors then
		hasImplementedDefaultSpawnBehaviors = true
		logger:trace("Implementing default BoxSpawnBehaviors")
		for _, child in defaultSpawnBehaviors:GetChildren() do
			if child:IsA("ModuleScript") then
				logger:trace("Now trying to implement BoxSpawnBehavior", child:GetFullName())
				self:implementSpawnBehavior((require)(child))
			end
		end
	end

	kit:tag("Box", prelude.isBasePart):onLoaded(onBoxLoaded)
end

return Box
