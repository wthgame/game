local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local ShouldPrompt = prelude.attribute("ShouldPrompt", prelude.isBoolean, false)
local TowerName = prelude.attribute("TowerName", prelude.isString)

local function promptToLoadTower(towerName: string)
	std.bindings._callBinding("@game/TowerRunController/promptToLoadTower", towerName)
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local TowerPortal = kit:tag("TowerPortal", prelude.isBasePart)

	TowerPortal:onLoaded(function(trove, portal)
		if not ShouldPrompt(portal) then
			return
		end

		local promptAttachment = trove:add(Instance.new("Attachment"))
		promptAttachment.Name = "TowerPortalPromptAttachment"

		local towerPrompt = trove:add(Instance.new("ProximityPrompt"))
		towerPrompt.Name = "TowerPortalPrompt"
		towerPrompt.ActionText = "Enter Tower"
		towerPrompt.RequiresLineOfSight = false
		towerPrompt.Parent = promptAttachment

		promptAttachment.Parent = portal

		trove:add(towerPrompt.Triggered:Connect(function(player)
			-- TODO: is this check needed?
			if Players.LocalPlayer == player then
				promptToLoadTower(TowerName:assert(portal) :: string)
			end
		end))
	end)
end

return self
