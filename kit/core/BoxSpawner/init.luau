--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Button = require(script.Parent:WaitForChild("Button"))
local PressOffset = Button.PressOffset
local PressTime = Button.PressTime
local PressEasingStyle = Button.PressEasingStyle
local PressEasingDirection = Button.PressEasingDirection
local bindActivationToTrove = Button.bindActivationToTrove

export type BoxBehavior = "Unanchoring" | "Draggable" | "Pickupable"

local BoxId = utils.attribute("BoxId", utils.t.string)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)
local BoxBehavior =
	utils.attribute("BoxBehavior", utils.t.literal("Unanchoring", "Draggable", "Pickupable"), "Unanchoring")

local trackedBoxes: utils.InstanceByIds<BasePart, string> = utils.trackInstanceByIds()
local spawnBoxTroves: utils.Map<BasePart, utils.Trove> = {}

local function spawnBoxesWithId(trove: utils.Trove, id: string)
	for box in trackedBoxes:getId(id) do
		print(box)
		local clonedBox = trove:clone(box)
		clonedBox.Parent = workspace
	end
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local BoxSpawner = kit:tag("BoxSpawner", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)
	local Box = kit:tag("Box", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Box:onLoaded(function(trove, box)
		local id = BoxId(box)
		assert(id, `No BoxId attribute for Box ${box:GetFullName()}`)
		trackedBoxes:add(box, id)
		box.Parent = nil
		trove:add(function()
			trackedBoxes:remove(box, id)
		end)
	end)

	BoxSpawner:onLoaded(function(trove, spawner)
		local activationTrove = trove:extend()

		local debounce = false
		local function trySpawn()
			if debounce or not utils.Active(spawner) then
				return
			end

			debounce = true

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
				debounce = false
				activationTrove = trove:extend()
				bindActivationToTrove(activationTrove, spawner, trySpawn)
			end

			task.delay(Cooldown(spawner), reset)
		end

		bindActivationToTrove(activationTrove, spawner, trySpawn)

		trove:connect(spawner:GetAttributeChangedSignal("ActivatedBy"), function()
			activationTrove:clean()
			activationTrove = trove:extend()
			bindActivationToTrove(activationTrove, spawner, trySpawn)
		end)
	end)

	Box:onLoaded(function(trove, box) end)
end

return self
