--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Button = require(script.Parent:WaitForChild("Button"))
local PressOffset = Button.PressOffset
local PlaySound = Button.PlaySound

export type BoxBehavior = "Unanchoring" | "Draggable" | "Pickupable"

local BoxId = utils.attribute("BoxId", utils.t.string)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
-- local BoxBehavior: utils.InstanceAttribute<BoxBehavior> = (
-- 	utils.attribute("BoxBehavior", utils.t.literal("Unanchoring", "Draggable", "Pickupable"), "Unanchoring")
-- )

local idToBox: utils.MapSet<string, BasePart> = utils.MapSet()
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
		utils.inferAndPlaySound(spawner, utils.AUDIO_ASSETS["core/towerSfx/button"], "Press")
	end

	if spawner.Anchored then
		utils.tweenMaybeInstant(
			spawner,
			{ CFrame = spawner.CFrame * utils.intoCFrameOffset(PressOffset(spawner)) },
			utils.tweenConfigFromAttributes(spawner, "Press")
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
		utils.connectActivation(trove, spawner, trySpawn)
	end

	task.delay(Cooldown(spawner), reset)
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local BoxSpawner = kit:tag("BoxSpawner", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)
	local Box = kit:tag("Box", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

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
