--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "TowerPortal"

function mech:init(wth)
	local TowerPortal: utils.Entity<BasePart> = wth:useTag("TowerPortal", utils.t.instanceIsA("BasePart"))
	local TowerName = wth:useAttribute("TowerName", TowerPortal, utils.t.string, "")
	local ShouldPrompt = wth:useAttribute("ShouldPrompt", TowerPortal, utils.t.boolean, true)

	local TowerPrompt: utils.Entity<ProximityPrompt> = wth.world:component()

	local function createTowerPrompt(trove: utils.Trove, id: utils.Entity, portal: BasePart)
		local promptAttachment = trove:add(Instance.new("Attachment"))
		promptAttachment.Name = "TowerPortalPromptAttachment"

		local towerPrompt = trove:add(Instance.new("ProximityPrompt"))
		towerPrompt.Name = "TowerPortalPrompt"
		towerPrompt.ActionText = "Enter Tower"
		towerPrompt.Parent = promptAttachment

		promptAttachment.Parent = portal

		trove:add(towerPrompt.Triggered:Connect(function(player)
			if Players.LocalPlayer ~= player then
				return
			end

			local name = wth.world:get(id, TowerName)
			if name then
				utils.promptToLoadTower(name)
			end
		end))

		wth.world:set(id, TowerPrompt, towerPrompt)

		return towerPrompt
	end

	local queryTowerPortals = wth.world:query(TowerPortal, ShouldPrompt):cached()

	local function checkTowerPortals(_, trove: utils.Trove)
		for id, portal, shouldPrompt in queryTowerPortals:iter() do
			if shouldPrompt then
				if not wth.world:has(id, TowerPrompt) then
					createTowerPrompt(trove, id, portal)
				end

				return
			end

			if not utils.isLocalPlayerCharacterTouchingPart(portal) then
				continue
			end
		end
	end

	wth:schedule(checkTowerPortals)
end

return mech
