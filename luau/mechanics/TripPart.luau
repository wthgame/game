--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

type DamageType = number | "Normal" | "Heavy" | "Lethal"

local TRIP_PART_TOUCH_CONFIG: utils.TouchConfig = {
	passLocalPlayerCharacters = true,
}

local mech = {} :: utils.Mechanic
mech.type = "Mechanic"
mech.name = "TripPart"

function mech:init(wth)
	local TripPart: utils.Entity<BasePart> = wth:useTag("TripPart", utils.t.instanceIsA("BasePart"))
	local queryTripPart = wth.world:query(TripPart):cached()

	local function checkTripParts()
		local humanoid = utils.getMaybeHumanoid()
		if not humanoid then
			return
		end

		for entity, part in queryTripPart:iter() do
			for _, toucher in workspace:GetPartsInPart(part) do
				if utils.checkTouched(toucher, TRIP_PART_TOUCH_CONFIG) then
					humanoid.Sit = true
				end
			end
		end
	end

	wth:schedule(checkTripParts)
end

return mech
