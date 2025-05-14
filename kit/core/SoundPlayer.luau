--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local PlayFromAssets = prelude.attribute("PlayFromAssets", prelude.t.keyOf(prelude.AUDIO_ASSETS) :: std.check<string>)
local Spatial = prelude.attribute("Spatial", prelude.t.boolean, false)
local Volume = prelude.attribute("Volume", prelude.t.numberPositive)
local Speed = prelude.attribute("Speed", prelude.t.numberPositive)

local self = {} :: std.KitScript
self.type = "KitScript"

local function playSound(_, player: Instance)
	local isSpatial = Spatial(player)
	local playFrom = if isSpatial then player else nil
	local assetKey = PlayFromAssets(player)
	local config: std.PlaySoundConfig = {
		volume = Volume(player),
		speed = Speed(player),
	}
	if assetKey then
		return prelude.playSoundFromGameAssets(assetKey, playFrom, config)
	end
	prelude.inferAndPlaySound(player, nil, "Sound", config, isSpatial)
end

function self:run(kit: std.Kit)
	local SoundPlayer = kit:tag("SoundPlayer")
	SoundPlayer:onActivated(playSound)
end

return self
