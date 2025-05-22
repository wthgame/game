--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude
local TeleporterDestination = require("./TeleporterDestination")

--- @type SeamlessMeasurement "Relative" | "World"
--- @within Teleporter
---
--- The proportions used to calculate the teleport if `Seamless` is enabled.
--- Relative proportions use percentage proportions of the `Teleporter` and the
--- `TeleporterDestination`. World proportions use studs of the `Teleporter` and
--- the `TeleporterDestination`
export type SeamlessMeasurement = "Relative" | "World"

local debounce = false
local debouncedTeleporters: std.Set<BasePart> = {}
local logger = prelude.createLogger("Teleporter")

--- @class Teleporter
--- @tag KitObject
--- @tag Activatable
---
--- Teleports the player to a random `TeleporterDestination` of the same
--- `TeleporterId`.
local Teleporter = {}
type Self = typeof(Teleporter)
Teleporter.implements = { KitScript = true }

--- @prop TeleporterId string
--- @within Teleporter
--- @tag Attribute
---
--- The group of teleporter destinations to pick randomly and teleport to.
Teleporter.TeleporterId = TeleporterDestination.TeleporterId

--- @prop KeepVelocity boolean
--- @within Teleporter
--- @tag Attribute
---
--- Whether the player should retain the velocity they were at prior to entering
--- the teleporter.
Teleporter.KeepVelocity = prelude.attribute("KeepVelocity", prelude.isBoolean, true)

--- @prop Cooldown boolean
--- @within Teleporter
--- @tag Attribute
---
--- Defines the cooldown period in seconds after a `Teleporter` has been
--- activated, before it can be used again.
Teleporter.Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)

--- @prop PlaySound boolean
--- @within Teleporter
--- @tag Attribute
---
--- Whether this should play a sound effect when teleported.
Teleporter.PlaySound = prelude.attribute("PlaySound", prelude.isBoolean, true)

--- @prop Seamless boolean
--- @within Teleporter
--- @tag Attribute
---
--- Whether the player should keep their relative CFrame to the center of the
--- teleporter prior to teleporting. For example, if the player activated
--- the teleporter from the bottom northwest of the teleporter, the player will
--- end up in the bottom northwest of the destination.
Teleporter.Seamless = prelude.attribute("Seamless", prelude.isBoolean, false)

--- @prop SeamlessMeasurement SeamlessMeasurement
--- @within Teleporter
--- @tag Attribute
---
--- The proportions used to calculate the teleport if `Seamless` is enabled.
--- Relative proportions use percentage proportions of the `Teleporter` and the
--- `TeleporterDestination`. World proportions use studs of the `Teleporter` and
--- the `TeleporterDestination`
Teleporter.SeamlessMeasurement = prelude.attribute(
	"SeamlessMeasurement",
	prelude.t.literal("Relative", "World"),
	"Relative"
) :: std.Attribute<SeamlessMeasurement>

--- @prop SeamlessOverflow boolean
--- @within Teleporter
--- @tag Attribute
---
--- Whether a teleport can exceed the bounds of the TeleporterDestination when
--- `Seamless` is enabled.
Teleporter.SeamlessOverflow = prelude.attribute("SeamlessOverflow", prelude.isBoolean, false)

local function calculateTeleportCFrame(teleporter: BasePart, destination: BasePart, root: BasePart)
	local destinationCFrame = destination.CFrame
	if Teleporter.Seamless(teleporter) then
		local rootPosition = root.Position
		local teleporterPosition = teleporter.Position

		local distance = rootPosition - teleporterPosition

		local measurement = Teleporter.SeamlessMeasurement(teleporter)
		if measurement == "World" then
			if not Teleporter.SeamlessOverflow(teleporter) then
				local destinationSize = destination.Size
				local sizeX, sizeY, sizeZ = destinationSize.X, destinationSize.Y, destinationSize.Z
				local halfSizeX, halfSizeY, halfSizeZ = sizeX / 2, sizeY / 2, sizeZ / 2
				distance = Vector3.new(
					math.clamp(distance.X, -halfSizeX, halfSizeX),
					math.clamp(distance.Y, -halfSizeY, halfSizeY),
					math.clamp(distance.Z, -halfSizeZ, halfSizeZ)
				)
			end
			destinationCFrame = destination.CFrame * CFrame.new(distance)
		else
			distance /= teleporter.Size
			if not Teleporter.SeamlessOverflow(teleporter) then
				distance = Vector3.new(
					math.clamp(distance.X, -0.5, 0.5),
					math.clamp(distance.Y, -0.5, 0.5),
					math.clamp(distance.Z, -0.5, 0.5)
				)
			end
			destinationCFrame = destination.CFrame * CFrame.new(destination.Size * distance)
		end
	end
	return destinationCFrame * std.physics.intoCFrameOffset(TeleporterDestination.TeleporterOffset(destination))
end

local function teleport(trove: std.Trove, teleporter: BasePart)
	local root = prelude.getMaybeHumanoidRootPart()
	if not root then
		return
	end

	if debounce or debouncedTeleporters[teleporter] then
		return
	end

	prelude.Activatable:set(teleporter, false)

	local allDestinations = (
		TeleporterDestination.idToDestination:get(Teleporter.TeleporterId:assert(teleporter) :: string)
	)

	local _, first = next(allDestinations)
	if not first then
		return
	end

	debounce = true
	debouncedTeleporters[teleporter] = true
	task.delay(Teleporter.Cooldown(teleporter), function(teleporter)
		debouncedTeleporters[teleporter] = nil
	end, teleporter)

	local len = #allDestinations

	local originalLinearVelocity = root.AssemblyLinearVelocity
	local originalAngularVelocity = root.AssemblyAngularVelocity

	local targetDestination = if len == 1
		then first
		else allDestinations[Random.new(os.clock() ^ 2):NextInteger(1, len)]

	if Teleporter.PlaySound(teleporter) then
		prelude.inferAndPlaySound(teleporter, prelude.AUDIO_ASSETS["core/towerSfx/teleport"], "TeleportSound")
	end

	local targetCFrame = calculateTeleportCFrame(teleporter, targetDestination, root)
	local config = prelude.tweenConfigFromAttributes(teleporter, "Transition")

	local wasAnchored = root.Anchored
	if not config.time or config.time == 0 then
		root:PivotTo(targetCFrame)
	else
		root.Anchored = true
		prelude.tween(root, { CFrame = targetCFrame }, config).Completed:Wait()
		root = prelude.getMaybeHumanoidRootPart()
	end

	if root then
		root.Anchored = wasAnchored
		if Teleporter.KeepVelocity(teleporter) then
			root.AssemblyLinearVelocity = originalLinearVelocity
			root.AssemblyAngularVelocity = originalAngularVelocity
		end
	end

	debounce = false
	prelude.Activatable:set(teleporter, true)
end

function Teleporter.run(self: Self, kit: std.Kit)
	kit:tag("Teleporter", prelude.isBasePart):onActivated(teleport)
end

return Teleporter
