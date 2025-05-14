--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local Button = require(script.Parent:WaitForChild("Button"))
local PressOffset = Button.PressOffset
local PlaySound = Button.PlaySound

export type BoxBehavior = "Unanchoring" | "Draggable" | "Pickupable"

local BoxId = prelude.attribute("BoxId", prelude.isString)
local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
-- local BoxBehavior: utils.InstanceAttribute<BoxBehavior> = (
-- 	prelude.attribute("BoxBehavior", prelude.t.literal("Unanchoring", "Draggable", "Pickupable"), "Unanchoring")
-- )

local idToBox: utils.MapSet<string, BasePart> = utils.collections.MapSet()
local spawnBoxTroves: utils.Map<BasePart, utils.Trove> = {}

local debouncedSpawners: utils.Set<BasePart> = {}

local function spawnBoxesWithId(trove: utils.Trove, id: string)
	for box in idToBox:get(id) do
		local clonedBox = trove:clone(box)
		clonedBox.Parent = workspace
	end
end

local function trySpawn(trove: utils.Trove, spawner: BasePart, activationTrove: utils.Trove)
	if debouncedSpawners[spawner] then
		return
	end

	debouncedSpawners[spawner] = true

	local existingSpawnTrove = spawnBoxTroves[spawner]
	if existingSpawnTrove then
		existingSpawnTrove:clean()
		spawnBoxTroves[spawner] = nil
	end

	activationTrove:clean()

	if PlaySound(spawner) then
		prelude.inferAndPlaySound(spawner, prelude.AUDIO_ASSETS["core/towerSfx/button"], "Press")
	end

	if spawner.Anchored then
		prelude.tweenMaybeInstant(
			spawner,
			{ CFrame = spawner.CFrame * utils.physics.intoCFrameOffset(PressOffset(spawner)) },
			prelude.tweenConfigFromAttributes(spawner, "Press")
		)
	end

	local id = BoxId(spawner)
	assert(id, `No BoxId attribute for BoxSpawner {spawner:GetFullName()}`)
	local spawnTrove = trove:extend()
	spawnBoxTroves[spawner] = spawnTrove
	spawnBoxesWithId(spawnTrove, id)

	local function reset()
		debouncedSpawners[spawner] = nil
		activationTrove:clean()
		prelude.connectActivation(trove, spawner, trySpawn)
	end

	task.delay(Cooldown(spawner), reset)
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local BoxSpawner = kit:tag("BoxSpawner", prelude.isBasePart)
	local Box = kit:tag("Box", prelude.isBasePart)

	Box:onLoaded(function(trove, box)
		local id = BoxId:assert(box) :: string
		idToBox:add(id, box)
		box.Parent = nil
		trove:add(function()
			idToBox:remove(id, box)
		end)
	end)

	BoxSpawner:onActivated(trySpawn)

	Box:onLoaded(function(trove, box) end)
end

return self
