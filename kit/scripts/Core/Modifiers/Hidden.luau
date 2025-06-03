--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local CLASS_HIDE_PROPERTIES: std.Map<string, std.Map<string, unknown>> = {
	BasePart = {
		Transparency = 1,
	},
	ImageLabel = {
		ImageTransparency = 1,
	},
	ImageButton = {
		ImageTransparency = 1,
	},
	TextLabel = {
		TextTransparency = 1,
	},
	TextButton = {
		TextTransparency = 1,
	},
	TextBox = {
		TextTransparency = 1,
	},
	Frame = {
		BackgroundTransparency = 1,
	},
	ParticleEmitter = {
		Enabled = false,
		Transparency = NumberSequence.new(1),
	},
	Beam = {
		Enabled = false,
		Transparency = NumberSequence.new(1),
	},
	Trail = {
		Enabled = false,
		Transparency = NumberSequence.new(1),
	},
}

--- @class Hidden
--- @tag KitObject
---
--- Visually hides the tagged instance. Useful when working with bigger objects
--- that benefit from being visible while editing, but should be hidden while
--- playing a tower.
local Hidden = {}
type Self = typeof(Hidden)
Hidden.implements = { KitScript = true }

--- @prop HideDescendants boolean
--- @tag Attribute
--- @within Hidden
---
--- Whether descendants should be hidden as well. Turning on `HideDescendants`
--- on a Model of Folder of objects is more managable than manually tagging
--- each child.
Hidden.HideDescendants = prelude.Attribute("HideDescendants", prelude.isBoolean, true)

function Hidden.run(self: Self, kit: std.Kit)
	local function hide(target: Instance)
		for class, properties in CLASS_HIDE_PROPERTIES do
			if target:IsA(class) then
				for property, value in properties do
					(target :: any)[property] = value
				end
			end
		end
	end

	local function hideLoaded(_, target: Instance)
		hide(target)
		if self.HideDescendants(target) then
			for _, descendant in target:GetDescendants() do
				task.spawn(hide, target)
			end
		end
	end

	kit:tag("Hidden"):onLoaded(hideLoaded)
end

return Hidden
