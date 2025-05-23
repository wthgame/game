--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local BoxTypes = require("../BoxTypes")

local Unanchoring = {} :: BoxTypes.BoxSpawnBehavior
Unanchoring.implements = { BoxSpawnBehavior = true }
Unanchoring.name = "Unanchoring"

function Unanchoring:spawn(_, box)
	box.Anchored = false
end

return Unanchoring
