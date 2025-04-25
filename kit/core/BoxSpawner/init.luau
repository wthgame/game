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
local glowButton = Button.glowButton

local BoxId = utils.attribute("BoxId", utils.t.string)
local Cooldown = utils.attribute("Cooldown", utils.t.numberPositive, 0)

local boxesById: utils.Map<string, utils.Set<BasePart>> = {}

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local BoxSpawner = kit:tag("BoxSpawner", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)
	local Box = kit:tag("Box", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	Box:onLoaded(function(trove, box)
		local boxes = boxesById[assert(BoxId(box))] or {}
		boxes[box] = true
		boxesById[assert(BoxId(box))] = boxes
		box.Parent = nil
	end)

	BoxSpawner:onLoaded(function(trove, spawner)
		local activationTrove = trove:extend()

		local debounce = false
		local function activateSpawner()
			if not utils.Active(spawner) then
				return
			end

			if debounce then
				return
			end
			debounce = true

			activationTrove:clean()
			utils.playSound(utils.SOUND_ASSETS.button)

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

			local function reset()
				debounce = false
				activationTrove = trove:extend()
				bindActivationToTrove(activationTrove, spawner, activateSpawner)
			end

			task.delay(Cooldown(spawner), reset)
		end

		bindActivationToTrove(activationTrove, spawner, activateSpawner)

		trove:connect(spawner:GetAttributeChangedSignal("ActivatedBy"), function()
			activationTrove:clean()
			activationTrove = trove:extend()
			bindActivationToTrove(activationTrove, spawner, activateSpawner)
		end)
	end)

	Box:onLoaded(function(trove, box) end)
end

return self
