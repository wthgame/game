local attributes = require("./attributes")
local t = require("./packages/t")
local trove = require("./packages/trove")

type ActivationBehaviorImpl = {
	predicate: ((instance: Instance) -> boolean)?,
	implement: (
		trove: trove.Trove,
		instance: Instance,
		onActivated: (trove: trove.Trove, instance: Instance) -> ()
	) -> (),
}

local function ActivationBehaviorImpl(x: ActivationBehaviorImpl)
	return table.freeze(x)
end

local activationBehaviorImpls = table.freeze({
	Touch = ActivationBehaviorImpl {
		predicate = t.instanceIsA("BasePart"),
		implement = function(trove, instance, onActivated)
			trove:connect((instance :: BasePart).Touched, function() end)
		end,
	},
	Prompt = ActivationBehaviorImpl {
		implement = function(trove, instance, onActivated) end,
	},
	Click = ActivationBehaviorImpl {
		implement = function(trove, instance, onActivated) end,
	},
	KeyCode = ActivationBehaviorImpl {
		implement = function(trove, instance, onActivated) end,
	},
	Interval = ActivationBehaviorImpl {
		implement = function(trove, instance, onActivated) end,
	},
	Node = ActivationBehaviorImpl {
		implement = function(trove, instance, onActivated) end,
	},
})

--- @class KitStdActivation
--- Implements activation for kit objects.
local activation = {}

--- @prop Activatable Attribute<boolean>
--- @within KitStdActivation
--- Whether if a kit object can be activated.
activation.Activatable = attributes.attribute("Activatable", t.boolean, false)

--- @prop ActivationBehavior Attribute<ActivationBehavior>
--- @within KitStdActivation
--- How to handle activation behavior.
activation.ActivationBehavior = attributes.attribute("ActivationBehavior", t.string)

function activation.onActivated() end

return table.freeze(activation)
