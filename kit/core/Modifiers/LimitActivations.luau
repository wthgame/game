--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @class LimitActivations
--- @tag KitObjectTag
---
--- Limits the amount of activations for a given kit object.
local self = {} :: std.KitScript
self.implements = { KitScript = true }

--- @prop MaxActivations number
--- @within LimitActivations
---
--- The amount of activations before the limited kit object should not be
--- activatable.
local MaxActivations = prelude.attribute("MaxActivations", prelude.isPositiveNumber, math.huge)

--- @prop ResetWhenUnactivatable boolean
--- @within LimitActivations
---
--- If a kit object should reset it's "activations count" when it's
--- `Activatable` attribute is disabled.
local ResetWhenUnactivatable = prelude.attribute("ResetWhenUnactivatable", prelude.isBoolean, true)

local activations: std.Map<Instance, number> = {}

local function loadLimitActivations(trove: std.Trove, limited: Instance)
	activations[limited] = 0
	trove:add(function()
		activations[limited] = nil
	end)
end

local function incrementActivations(_, activated: Instance)
	if activations[activated] <= MaxActivations(activated) then
		activations[activated] += 1
		return
	end
	prelude.Activatable:set(activated, false)
	if ResetWhenUnactivatable(activated) then
		activations[activated] = 0
	end
end

function self:run(kit: std.Kit)
	local LimitActivations = kit:tag("LimitActivations")
	LimitActivations:onLoaded(loadLimitActivations)
	LimitActivations:onActivated(incrementActivations)
end

return self
