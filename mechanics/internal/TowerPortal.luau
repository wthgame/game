local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TowerPortalAttributes = {
	ShouldPrompt: boolean,
	TowerName: string,
}

local function initTowerPortals(wth: utils.WTH)
	local TowerPortal = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "TowerPortal",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			ShouldPrompt = true,
			TowerName = "",
		},
		attributeChecks = {
			ShouldPrompt = utils.t.boolean,
			TowerName = utils.t.string,
		},
	} :: utils.Mechanic<BasePart, TowerPortalAttributes>

	function TowerPortal:loaded(trove, portal, kit)
		local shouldPrompt = self:attribute(portal, "ShouldPrompt")
		local towerName = self:attribute(portal, "TowerName")

		if shouldPrompt then
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
					utils.promptToStartNewTowerRun(towerName)
				end
			end))
		end
	end

	wth.registerMechanic(TowerPortal)
end

return initTowerPortals
