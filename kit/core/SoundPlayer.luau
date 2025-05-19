--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--[=[
    @class SoundPlayer
    @tag KitObjectTag
    SoundPlayers, when actviated, emit a sound effect inferred from it's
    attributes or children.

    The SoundPlayer will play the first thing found in order:

    1. A `PlayFromAssets` key
    2. A `Sound` attribute
    3. A `Sound` instance named "Sound"
]=]
local self = {} :: std.KitScript
self.implements = { KitScript = true }

--[=[
    @prop PlayFromAssets keyof<AUDIO_ASSETS>?
    @within SoundPlayer
    TBA
    This overrides the Sound attribute or a Sound instance.
]=]
local PlayFromAssets = prelude.attribute("PlayFromAssets", prelude.t.keyOf(prelude.AUDIO_ASSETS) :: std.check<string>)
--[=[
    @prop Spatial boolean
    @within SoundPlayer
    Toggles if the sound should be parented to the part, so played "spatially",
    or parented to nil, so played "globally".
]=]
local Spatial = prelude.attribute("Spatial", prelude.t.boolean, false)
--[=[
    @prop Volume number?
    @within SoundPlayer
    How loud should the sound be. If specified, this overrides the `Volume`
    property in any Sound instance.
]=]
local Volume = prelude.attribute("Volume", prelude.t.numberPositive)
--[=[
    @prop Speed number?
    @within SoundPlayer
    Divides the sound's duration, ie. value of 1 means normal speed, value
    of 2 means double speed, value of 0.5 means half speed. If specified, this
    overrides the `PlaybackSpeed` property in any Sound instance.
]=]
local Speed = prelude.attribute("Speed", prelude.t.numberPositive)
--[=[
    @prop Sound string?
    @within SoundPlayer
    An asset ID that should be used if a `PlayFromAssets` attribute or a
    `Sound` instance isn't present.
]=]

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
