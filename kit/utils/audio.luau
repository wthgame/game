--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING
-- TODO: warn for audios above 6 seconds

local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local assets = require("./assets")
local types = require("./types")

export type PlaySoundConfig = {
	speed: number?,
	volume: number?,
}

local SOUND_ASSETS = assets.SOUND_ASSETS
local DELETE_SOUNDS_AFTER_SECONDS = 1
local DEFAULT_PLAY_SOUND_CONFIG: types.PlaySoundConfig = {
	volume = 1,
	speed = 1,
}

local soundTimeLengths: { [string]: number } = {}

--- @within KitUtils
--- @tag Audio
--- Plays a sound from an asset string or cloned from a Sound instance.
local function playSound(asset: string | Sound, from: Instance?, config: types.PlaySoundConfig?)
	local speed = if config and config.speed then config.speed else DEFAULT_PLAY_SOUND_CONFIG.speed :: number

	local sound: Sound
	if typeof(asset) == "string" then
		sound = Instance.new("Sound")
		sound.Name = `Mechanics_playSound_{asset}`
		sound.SoundId = asset
	else
		sound = asset:Clone()
	end

	sound.PlaybackSpeed = config and config.speed or DEFAULT_PLAY_SOUND_CONFIG.speed :: number
	sound.Volume = config and config.volume or DEFAULT_PLAY_SOUND_CONFIG.volume :: number

	if not from then
		SoundService:PlayLocalSound(sound)
	else
		sound.Parent = from
		sound:Play()
	end

	Debris:AddItem(sound, (soundTimeLengths[sound.SoundId] or sound.TimeLength) * speed + DELETE_SOUNDS_AFTER_SECONDS)
end

--- @within KitUtils
--- @tag Audio
--- Plays a sound from the game's assets module. See the sounds table in the
--- Replicated.WTHShared.assets module for what sounds can be played.
local function playSoundFromGameAssets(key: string, from: Instance?, config: types.PlaySoundConfig?)
	local asset = assert(SOUND_ASSETS[key], `No sound exists in game assets called "{key}"`)
	local speed = if config and config.speed then config.speed else DEFAULT_PLAY_SOUND_CONFIG.speed :: number

	local sound = Instance.new("Sound")
	sound.Name = `Mechanics_playSound_{asset}`
	sound.SoundId = asset
	sound.PlaybackSpeed = speed
	sound.Volume = if config and config.volume then config.volume else DEFAULT_PLAY_SOUND_CONFIG.volume :: number

	if not from then
		SoundService:PlayLocalSound(sound)
	else
		sound.Parent = from
		sound:Play()
	end

	Debris:AddItem(sound, (soundTimeLengths[asset] or sound.TimeLength) * speed + DELETE_SOUNDS_AFTER_SECONDS)
end

--[=[
    @within KitUtils
    @tag Audio

    Tries to infer a sound from the instance's attributes or a Sound instance.
    If no sound is found, plays the specified default sound. Can specify the
    name of the attribute or child to search for, or defaults to searching for
    "Sound".

    ```Lua
    utils.inferAndPlaySound(btn, utils.SOUND_ASSETS.button, "PressSound")
    ```
]=]
local function inferAndPlaySound(
	instance: Instance,
	defaultSound: string?,
	searchFor: string?,
	config: types.PlaySoundConfig?,
	spatial: boolean?
)
	local spatial = if spatial == nil then instance:IsA("BasePart") else spatial
	local searchFor = searchFor or "Sound"
	local realSoundAttribute = instance:GetAttribute(searchFor)

	if realSoundAttribute and typeof(realSoundAttribute) == "string" then
		playSound(SOUND_ASSETS[realSoundAttribute] or realSoundAttribute, spatial and instance or nil, config)
		return
	end

	local realSoundInstance = instance:FindFirstChild(searchFor)
	if realSoundInstance and realSoundInstance:IsA("Sound") then
		local sound = realSoundInstance:Clone()
		local speed = if config and config.speed then config.speed else sound.PlaybackSpeed
		sound.PlaybackSpeed = speed

		if config then
			if config.volume then
				sound.Volume = config.volume
			end
		end

		if not spatial then
			SoundService:PlayLocalSound(sound)
			return
		end

		sound.Parent = instance
		sound:Play()
		Debris:AddItem(
			sound,
			(soundTimeLengths[sound.SoundId] or sound.TimeLength) * speed + DELETE_SOUNDS_AFTER_SECONDS
		)
		return
	end

	if defaultSound then
		playSound(defaultSound, spatial and instance or nil, config)
	end
end

for key, asset in pairs(SOUND_ASSETS) do
	task.spawn(function(key, asset)
		local preloadSound = Instance.new("Sound")
		preloadSound.Name = `Mechanics_preloadSound_${key}`
		preloadSound.SoundId = asset
		preloadSound.Parent = SoundService

		if not preloadSound.IsLoaded then
			preloadSound.Loaded:Wait()
		end

		soundTimeLengths[asset] = preloadSound.TimeLength
		preloadSound:Destroy()
	end, key, asset)
end

return {
	SOUND_ASSETS = SOUND_ASSETS,
	inferAndPlaySound = inferAndPlaySound,
	playSound = playSound,
	playSoundFromGameAssets = playSoundFromGameAssets,
}
