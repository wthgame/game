--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local isNumber = prelude.t.union(prelude.isPositiveNumber, prelude.t.NumberSequence)

local Turret = {}
type Self = typeof(Turret)
Turret.implements = { KitScript = true }

Turret.BulletPerSecond = prelude.Attribute("BulletPerSecond", prelude.isPositiveNumber, 1)
Turret.BulletSpeed = prelude.Attribute("BulletSpeed", isNumber)
Turret.BulletAcceleration = prelude.Attribute("BulletAcceleration", prelude.t.Vector3, Vector3.zero)
Turret.BulletSpreadAngle = prelude.Attribute("BulletSpreadAngle", prelude.t.Vector2, Vector2.zero)
Turret.BulletLifetime = prelude.Attribute("BulletLifetime", isNumber, 1)

function Turret.run(self: Self, kit: std.Kit) end

return Turret
