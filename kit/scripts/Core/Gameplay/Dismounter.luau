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

--- @prop Dismounts std.ManyAttribute<boolean>
--- @within Dismounter
--- @tag Attribute
---
--- When activated, dismounts the "X" object.
Dismounter.Dismounts = prelude.ManyAttribute("Dismounts", prelude.isBoolean)

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

local function dismount(_, dismounter: Instance)
	-- TODO: this returns Map<string, any>, is it worth perf for Set<string>?
	onDismount:Fire(Dismounter.Dismounts(dismounter) :: any)
end

function Dismounter:run(kit: std.Kit)
	local tag = kit:tag("Dismounter")
	tag:onActivated(dismount)
end

return Dismounter
