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

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local HideDescendants = prelude.attribute("HideDescendants", prelude.isBoolean, true)

function hide(target: Instance)
	for class, properties in CLASS_HIDE_PROPERTIES do
		if target:IsA(class) then
			for property, value in properties do
				(target :: any)[property] = value
			end
		end
	end
end

function hideLoaded(_, target: Instance)
	hide(target)
	if HideDescendants(target) then
		for _, descendant in target:GetDescendants() do
			task.spawn(hide, target)
		end
	end
end

function self:run(kit: std.Kit)
	local Hidden = kit:tag("Hidden")
	Hidden:onLoaded(hideLoaded)
end

return self
