--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @class TeleporterDestination
--- @tag KitObject
---
--- Destination that `Teleporter` with the same `TeleportId` will randomly pick
--- and teleport.
local TeleporterDestination = {}
type Self = typeof(TeleporterDestination)
TeleporterDestination.implements = { KitScript = true }

--- @prop idToDestination std.MapArray<string, BasePart>
--- @within TeleporterDestination
---
--- A `MapArray` from `TeleporterId` to `TeleporterDestination`s with that id.
TeleporterDestination.idToDestination = std.collections.MapArray() :: std.MapArray<string, BasePart>

--- @prop TeleporterId string
--- @within TeleporterDestination
--- @tag Attribute
---
--- The associated group of teleporters.
TeleporterDestination.TeleporterId = prelude.Attribute("TeleporterId", prelude.isString)

--- @prop TeleporterOffset number | Vector3 | CFrame
--- @within TeleporterDestination
--- @tag Attribute
---
--- How far from the center the player will be teleported to. Can be used to
--- shift players from clipping into the ground with a `TeleportDestination` on
--- the ground.
TeleporterDestination.TeleporterOffset = prelude.Attribute(
	"TeleportOffset",
	prelude.t.union(prelude.t.number, prelude.t.Vector3, prelude.t.CFrame),
	Vector3.new(0, 3, 0)
)

function TeleporterDestination.run(self: Self, kit: std.Kit)
	local tag = kit:tag("TeleporterDestination", prelude.isBasePart)
	tag:onLoaded(function(trove, destination)
		local id = self.TeleporterId(destination)
		if id then
			self.idToDestination:add(id, destination)
		end
		-- local previousId: string? = nil
		-- trove:connect(destination:GetAttributeChangedSignal(TeleporterId.name), function()
		-- 	local newId = TeleporterId(destination)
		-- 	if newId then
		-- 		if previousId ~= newId then
		-- 		    idToDestination:remove(previousId, destination)
		-- 		end
		-- 	elseif previousId then
		-- 	    idToDestination:remove(previousId, destination)
		-- 	end
		-- 	previousId = newId
		-- end)
		trove:add(function()
			local id = self.TeleporterId(destination)
			if id then
				self.idToDestination:remove(id, destination)
			end
		end)
	end)
end

return TeleporterDestination
