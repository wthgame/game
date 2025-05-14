--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local MinimumDistance = prelude.attribute("MinimumDistance", prelude.isPositiveNumber, 100)
local MaximumDistance = prelude.attribute("MaximumDistance", prelude.isPositiveNumber, math.huge)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local DistanceAnchoring = kit:tag("DistanceAnchoring")

	local localPlayer = Players.LocalPlayer

	kit:onPhysics(function()
		debug.profilebegin("DistanceAnchoring")
		for _, toAnchor in DistanceAnchoring:instances() do
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

return self
