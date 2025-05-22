--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local onDismount: std.LemonSignal<std.Set<string>> = std.packages.createLemonSignal()

--- @class Dismounter
--- @tag KitObject
--- @tag Activatable
---
--- Dismounts the player from mountable objects such as Vines, Seats and
--- Ziplines.
local Dismounter = {}
Dismounter.implements = { KitScript = true }

--- @prop Dismount_X boolean
--- @within Dismounter
--- @tag Attribute
---
--- When activated, dismounts the "X" object.

--- @prop onDismount std.LemonSignal<std.Set<string>>
--- @within Dismounter
---
--- The Dismounter exports a `onDismount` signal that is fired with a set of
--- objects to dismount. Users are expected to implement `onDismount` themself.
---
--- ```luau
--- -- within an `onActivated` callback:
--- local dismountTrove = trove:extend()
---
--- local function dismount()
---     dismountTrove:clean()
---     logger:info("Dismounted!")
--- end
---
--- dismountTrove:add(dismount)
---
--- dismountTrove:connect(Dismounter.onDismount :: any, function(objects)
---     if objects.MyKitObject then
---         dismount()
---     end
--- end)
--- ```
Dismounter.onDismount = onDismount

local logger = prelude.createLogger("Dismounter")

local function dismount(_, dismounter: Instance)
	local targets: std.Set<string> = {}
	for attribute, value in dismounter:GetAttributes() do
		local targetForAttribute = attribute:match("^Dismounts_(%w+)")
		if targetForAttribute and value then
			logger:trace("Dismounting", targetForAttribute)
			targets[targetForAttribute] = true
		end
	end
	onDismount:Fire(targets)
end

function Dismounter:run(kit: std.Kit)
	local tag = kit:tag("Dismounter")
	tag:onActivated(dismount)
end

return Dismounter
