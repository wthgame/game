local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local ShouldPrompt = utils.attribute("ShouldPrompt", utils.t.boolean, false)
local TowerName = utils.attribute("TowerName", utils.t.string)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local TowerPortal = kit:tag("TowerPortal", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

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
				utils._.callMechanicBinding("@game/TowerRunController/promptToLoadTower", TowerName(portal))
			end
		end))
	end)
end

return self
