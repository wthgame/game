--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude
local CatRom = std.packages.CatRom

export type CountSegmentsBy = "Auto" | "Manual"
export type RenderMode = "Once" | "EveryFrame"

type ZiplineInstance = BasePart & {
	Points: Instance,
}

local MAX_SEGMENTS = 200

local Zipline = {}
type Self = typeof(Zipline)
Zipline.implements = { KitScript = true }

Zipline.EndDismount = prelude.Attribute("EndDismount", prelude.isBoolean, true)
Zipline.AllowJumpDismount = prelude.Attribute("AllowJumpDismount", prelude.isBoolean, true)
Zipline.Controllable = prelude.Attribute("Controllable", prelude.isBoolean, false)
Zipline.KeepVelocity = prelude.Attribute("KeepVelocity", prelude.isBoolean, true)
Zipline.Speed = prelude.Attribute("Speed", prelude.isPositiveNumber, 1)
Zipline.Cooldown = prelude.Attribute("Cooldown", prelude.isPositiveNumber, 0)

Zipline.CurveAlpha = prelude.Attribute("CurveAlpha", prelude.isPositiveNumber, 1)
Zipline.CurveTension = prelude.Attribute("CurveTension", prelude.isPositiveNumber, 1)
Zipline.Loops = prelude.Attribute("Loops", prelude.isBoolean, false)

Zipline.CountSegmentsBy = prelude.Attribute("CountSegmentsBy", prelude.t.literal("Auto", "Manual"), "Auto")
Zipline.Segments = prelude.Attribute("Segments", prelude.t.numberConstrained(0, MAX_SEGMENTS), 20)
Zipline.SegmentRenderMode = prelude.Attribute("SegmentRenderMode", prelude.t.literal("Once", "EveryFrame"), "Once")

Zipline.PlayJumpSound = prelude.Attribute("PlayJumpSound", prelude.isBoolean, true)
Zipline.PlayGrabSound = prelude.Attribute("PlayGrabSound", prelude.isBoolean, true)

function Zipline.run(self: Self, kit: std.Kit)
	local tag = kit:tag(
		"Zipline",
		prelude.t.instanceIsA("BasePart", {
			Points = prelude.t.Instance,
		}) :: std.check<ZiplineInstance>
	)

	tag:onLoaded(function() end)
end

return Zipline
