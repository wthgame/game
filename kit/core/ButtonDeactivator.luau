--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local Button = require("./Button")
local ButtonId = Button.ButtonId
local idToButtonsPressed = Button.idToButtonsPressed
local updateId = Button.updateId

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function deactivate(_, deactivator: BasePart)
	local id = ButtonId(deactivator)
	if id then
		local buttons = idToButtonsPressed:get(id)
		for btn in buttons do
			-- NOTE: Button mechanic handles removing from idToButtonsPressed
			-- once it is deactivated
			btn:SetAttribute("ButtonPressed", false)
		end
		updateId(id)
	end
end

function self:run(kit: std.Kit)
	local ButtonDeactivator = kit:tag("ButtonDeactivator", prelude.isBasePart)
	ButtonDeactivator:onActivated(deactivate)
end

return self
