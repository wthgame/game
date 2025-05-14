--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

type VanishMode = "Oneshot" | "Blink" | "Constant"
type VanishStyle = "Disappear" | "Unanchor" | "Crumble" | "Scale"

local VanishMode: utils.InstanceAttribute<VanishMode> = (
	prelude.attribute("VanishMode", prelude.t.literal("Oneshot", "Blink", "Constant"), "Fade")
)
local VanishStyle: utils.InstanceAttribute<VanishStyle> = (
	prelude.attribute("VanishStyle", prelude.t.literal("Disappear", "Unanchor", "Crumble", "Scale"), "Disappear")
)
local VanishScale = prelude.attribute("VanishScale", prelude.t.Vector3, Vector3.zero)

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Vanisher = kit:tag("Vanisher", prelude.isBasePart)
end

return self
