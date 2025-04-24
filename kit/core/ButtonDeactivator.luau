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
			print("now touched, checking")

			if not utils.isToucher(deactivator, toucher) then
				return
			end

			print("is touched")

			local id = ButtonId(deactivator)
			if not id then
				return
			end

			print("deactivating", id)

			local buttons = buttonsPressedById[id]
			if buttons then
				for btn in buttons do
					print("deactivating btn", btn)
					btn:SetAttribute("ButtonPressed", false)
				end
			end

			updateId(id)
		end)
	end)
end

return self
