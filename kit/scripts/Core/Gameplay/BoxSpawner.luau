--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude
local siftDictionary = std.packages.sift.Dictionary
local Button = require("./Button")
local PressOffset = Button.PressOffset
local PlaySound = Button.PlaySound
local Box = require("./Box")

export type BoxBehavior = "Unanchoring" | "Draggable" | "Pickupable"

local REVERSE: std.TweenConfig = { reverse = true }

local BoxId = prelude.attribute("BoxId", prelude.isString)
local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)

local spawnBoxTroves: std.Map<BasePart, std.Trove> = {}

local debouncedSpawners: std.Set<BasePart> = {}

local function trySpawn(trove: std.Trove, spawner: BasePart)
	if debouncedSpawners[spawner] then
		return
	end

	prelude.Activatable:set(spawner, false)
	debouncedSpawners[spawner] = true

	local existingSpawnTrove = spawnBoxTroves[spawner]
	if existingSpawnTrove then
		existingSpawnTrove:clean()
		spawnBoxTroves[spawner] = nil
	end

	if PlaySound(spawner) then
		prelude.inferAndPlaySound(spawner, prelude.AUDIO_ASSETS["core/towerSfx/button"], "Press")
	end

	if spawner.Anchored then
		prelude.tweenMaybeInstant(
			spawner,
			{ CFrame = spawner.CFrame * std.physics.intoCFrameOffset(PressOffset(spawner)) },
			siftDictionary.merge(prelude.tweenConfigFromAttributes(spawner, "Press"), REVERSE)
		)
	end

	local id = BoxId:assert(spawner) :: string
	local spawnTrove = trove:extend()
	spawnBoxTroves[spawner] = spawnTrove
	Box:spawnBoxesWithId(spawnTrove, id)

	local function reset()
		debouncedSpawners[spawner] = nil
		prelude.Activatable:set(spawner, true)
	end

	task.delay(Cooldown(spawner), reset)
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	kit:tag("BoxSpawner", prelude.isBasePart):onActivated(trySpawn)
end

return self
