--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type Mode = "Boost" | "Zone" | "Reset"
type PlayerStat = "Walkspeed" | "JumpPower"

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "PlayerStatChanger"

function mech:init(wth)
	local PlayerStatChanger: utils.Entity<BasePart> = wth:useTag("PlayerStatChanger", utils.t.instanceIsA("BasePart"))

	local Mode: utils.Entity<Mode> =
		wth:useAttribute("Mode", PlayerStatChanger, utils.t.literal("Boost", "Zone", "Reset") :: any, "Boost")
	local PlayerStat: utils.Entity<PlayerStat> =
		wth:useAttribute("PlayerStat", PlayerStatChanger, utils.t.literal("Walkspeed", "JumpPower") :: any, "Walkspeed")
	local Value = wth:useAttribute("Value", Mode, utils.t.numberPositive, 0)
	local Duration = wth:useAttribute("Duration", Mode, utils.t.numberPositive, 0)
	local Cooldown = wth:useAttribute("Cooldown", Mode, utils.t.numberPositive, 0)

	local queryPlayerStatChanger =
		wth.world:query(PlayerStatChanger, Mode, PlayerStat, Value, Duration, Cooldown):cached()

	local function checkPlayerStatChangers(_, trove: utils.Trove)
		for entity, changer, mode, stat, value, duration, cooldown in queryPlayerStatChanger:iter() do
		end
	end

	wth:schedule(checkPlayerStatChangers)
end

return mech
