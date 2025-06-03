--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local MinimumDistance = prelude.Attribute("MinimumDistance", prelude.isPositiveNumber, 100)
local MaximumDistance = prelude.Attribute("MaximumDistance", prelude.isPositiveNumber, math.huge)

--- @class DistanceAnchoring
--- @tag KitObject
---
--- Anchors an object unless it's in a given distance. Useful for performance
--- especially with physical moving objects that should be anchored when not
--- visible.
---
--- It is discouraged from using this kit object for tower gameplay.
local DistanceAnchoring = {}
type Self = typeof(DistanceAnchoring)
DistanceAnchoring.implements = { KitScript = true }

function DistanceAnchoring:run(kit: std.Kit)
	local tag = kit:tag("DistanceAnchoring")

	local localPlayer = Players.LocalPlayer

	kit:onPhysics(function()
		debug.profilebegin("DistanceAnchoring")

		for _, toAnchor in tag:instances() do
			if toAnchor:IsA("BasePart") then
				local distance = localPlayer:DistanceFromCharacter(toAnchor.Position)
				local shouldAnchor = distance >= MinimumDistance(toAnchor) and distance <= MaximumDistance(toAnchor)
				if toAnchor.Anchored ~= shouldAnchor then
					toAnchor.Anchored = shouldAnchor
				end
			end
		end

		debug.profileend()
	end)
end

return DistanceAnchoring
