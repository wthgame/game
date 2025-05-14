--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))
local prelude = utils.prelude

local Button = require("./Button")
local ButtonId = Button.ButtonId
local idToButtonsPressed = Button.idToButtonsPressed
local updateId = Button.updateId

local self = {} :: utils.KitScript
self.type = "KitScript"

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

function self:run(kit: utils.Kit)
	local ButtonDeactivator = kit:tag("ButtonDeactivator", prelude.isBasePart)

	ButtonDeactivator:onActivated(deactivate)
end

return self
