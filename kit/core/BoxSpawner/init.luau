--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Button = require(script.Parent:WaitForChild("Button"))
local PressOffset = Button.PressOffset
local PressTime = Button.PressTime
local PressEasingStyle = Button.PressEasingStyle
local PressEasingDirection = Button.PressEasingDirection

export type BoxBehavior = "Unanchoring" | "Draggable" | "Pickupable"

local BoxId = utils.attribute("BoxId", utils.t.string)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
-- local BoxBehavior: utils.InstanceAttribute<BoxBehavior> = (
-- 	utils.attribute("BoxBehavior", utils.t.literal("Unanchoring", "Draggable", "Pickupable"), "Unanchoring")
-- )

local trackedBoxes: utils.MapSet<string, BasePart> = utils.MapSet()
local spawnBoxTroves: utils.Map<BasePart, utils.Trove> = {}

local debouncedSpawners: utils.Set<BasePart> = {}

local function spawnBoxesWithId(trove: utils.Trove, id: string)
	for box in trackedBoxes:get(id) do
		print(box)
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
	utils.inferAndPlaySound(spawner, utils.SOUND_ASSETS.button)

	if spawner.Anchored then
		local pressOffset = PressOffset(spawner)
		local finalPressOffset = CFrame.new(Vector3.yAxis * -0.75)
		if typeof(pressOffset) == "number" then
			finalPressOffset = CFrame.new(Vector3.yAxis * -pressOffset)
		elseif typeof(pressOffset) == "Vector3" then
			finalPressOffset = CFrame.new(pressOffset)
		elseif typeof(pressOffset) == "CFrame" then
			finalPressOffset = pressOffset
		end

		utils.tweenMaybeInstant(spawner, { CFrame = spawner.CFrame * finalPressOffset }, {
			time = PressTime(spawner),
			easingStyle = PressEasingStyle(spawner),
			easingDirection = PressEasingDirection(spawner),
			reverse = true,
		})
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
		trackedBoxes:add(id, box)
		box.Parent = nil
		trove:add(function()
			trackedBoxes:remove(id, box)
		end)
	end)

	BoxSpawner:connectActivation(trySpawn)

	Box:onLoaded(function(trove, box) end)
end

return self
