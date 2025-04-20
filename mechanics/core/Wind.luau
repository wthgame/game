--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Vector = "Up" | "Right" | "Look" | "Z"

type WindAttributes = {
	Enabled: boolean,
	Power: number,
	MaxForce: number,
	Vector: Vector,
	SupportsLocalCharacter: boolean,
}

local function init(wth: utils.WTH)
	local Wind = {
		type = "Mechanic",
		minimumKitVersion = "1",
		instanceTag = "Wind",
		instanceCheck = utils.t.instanceIsA("BasePart"),
		defaultAttributes = {
			Enabled = true,
			Power = 0,
			MaxForce = math.huge,
			Vector = "Up",
			SupportsLocalCharacter = true,
		},
		attributeChecks = {
			Enabled = utils.t.boolean,
			Power = utils.t.numberPositive,
			MaxForce = utils.t.numberPositive,
			Vector = utils.t.literal("Up", "Right", "Look", "Z"),
			SupportsLocalCharacter = utils.t.boolean,
		},
	} :: utils.Mechanic<BasePart, WindAttributes>

	function Wind:loaded(trove, instance) end

	wth.registerMechanic(Wind)
end

return init

-- 	local Elevator: utils.Entity<BasePart> = wth:useTag("Elevator", utils.t.instanceIsA("BasePart"))
-- 	local Speed = wth:useAttribute("Speed", Elevator, utils.t.numberPositive, 0)
-- 	local MaxForce = wth:useAttribute("MaxForce", Elevator, utils.t.numberPositive, math.huge)
-- 	local Vector = wth:useAttribute("Vector", Elevator, isAllowedCFrameComponent, "UpVector")
-- 	local PassCharacter = wth:useAttribute("PassCharacter", Elevator, utils.t.boolean, true)
