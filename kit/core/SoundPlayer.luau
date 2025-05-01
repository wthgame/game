--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local PlayFromAssets = utils.attribute("PlayFromAssets", utils.t.keyOf(utils.SOUND_ASSETS) :: utils.check<string>)
local Spatial = utils.attribute("Spatial", utils.t.boolean, false)
local Volume = utils.attribute("Volume", utils.t.numberPositive)
local Speed = utils.attribute("Speed", utils.t.numberPositive)

local self = {} :: utils.KitScript
self.type = "KitScript"

local function playSound(_, player: Instance)
	local isSpatial = Spatial(player)
	local playFrom = if isSpatial then player else nil
	local assetKey = PlayFromAssets(player)
	local config: utils.PlaySoundConfig = {
		volume = Volume(player),
		speed = Speed(player),
	}
	if assetKey then
		return utils.playSoundFromGameAssets(assetKey, playFrom, config)
	end
	utils.inferAndPlaySound(player, nil, "Sound", config, isSpatial)
end

function self:run(kit: utils.Kit)
	local SoundPlayer = kit:tag("SoundPlayer")
	SoundPlayer:onLoaded(function(trove, player)
		utils.connectActivation(trove, player, playSound)
	end)
end

return self
