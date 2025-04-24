--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local Button = require("./Button")
local ButtonId = Button.ButtonId
local buttonsPressedById = Button.buttonsPressedById
local updateId = Button.updateId

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local ButtonDeactivator = kit:tag("ButtonDeactivator", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	ButtonDeactivator:onLoaded(function(trove, deactivator)
		trove:connect(deactivator.Touched, function(toucher)
			local id = ButtonId(deactivator)
			if utils.Active(deactivator) and utils.isToucher(deactivator, toucher) and id then
				local buttons = buttonsPressedById[id]
				if buttons then
					for btn in buttons do
						btn:SetAttribute("ButtonPressed", false)
					end
					updateId(id)
				end
			end
		end)
	end)
end

return self
