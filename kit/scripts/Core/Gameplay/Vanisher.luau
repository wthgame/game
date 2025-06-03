--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

type VanishMode = "Oneshot" | "Blink" | "Constant"
type VanishStyle = "Disappear" | "Unanchor" | "Crumble" | "Scale"

local VanishMode: std.Attribute<VanishMode> = (
	prelude.Attribute("VanishMode", prelude.t.literal("Oneshot", "Blink", "Constant"), "Fade")
)
local VanishStyle: std.Attribute<VanishStyle> = (
	prelude.Attribute("VanishStyle", prelude.t.literal("Disappear", "Unanchor", "Crumble", "Scale"), "Disappear")
)
local VanishScale = prelude.Attribute("VanishScale", prelude.t.Vector3, Vector3.zero)

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Vanisher = kit:tag("Vanisher", prelude.isBasePart)
end

return self
