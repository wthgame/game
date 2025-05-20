--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local TeleporterId = prelude.attribute("TeleporterId", prelude.isString)
local KeepVelocity = prelude.attribute("KeepVelocity", prelude.isBoolean, true)
local Cooldown = prelude.attribute("Cooldown", prelude.isPositiveNumber, 0)
local PlaySound = prelude.attribute("PlaySound", prelude.isBoolean, true)
local TeleporterOffset = prelude.attribute(
	"TeleportOffset",
	prelude.t.union(prelude.t.number, prelude.t.Vector3, prelude.t.CFrame),
	Vector3.new(0, 3, 0)
)

-- NOTE: using MapArray to use random teleporter destinations
local idToDestination: std.MapArray<string, BasePart> = std.collections.MapArray()
local debounce = false
local debouncedTeleporters: std.Set<BasePart> = {}

local function teleport(trove: std.Trove, teleporter: BasePart)
	local root = prelude.getMaybeHumanoidRootPart()
	if not root then
		return
	end

	if debounce or debouncedTeleporters[teleporter] then
		return
	end

	prelude.Activatable:set(teleporter, false)

	local allDestinations = idToDestination:get(TeleporterId:assert(teleporter) :: string)

	local _, first = next(allDestinations)
	if not first then
		return
	end

	debounce = true
	debouncedTeleporters[teleporter] = true
	task.delay(Cooldown(teleporter), function(teleporter)
		debouncedTeleporters[teleporter] = nil
	end, teleporter)

	local len = #allDestinations

	local originalLinearVelocity = root.AssemblyLinearVelocity
	local originalAngularVelocity = root.AssemblyAngularVelocity

	local targetDestination = if len == 1
		then first
		else allDestinations[Random.new(os.clock() ^ 2):NextInteger(1, len)]

	local targetCFrame = targetDestination:GetPivot()
		* std.physics.intoCFrameOffset(TeleporterOffset(targetDestination))

	if PlaySound(teleporter) then
		prelude.inferAndPlaySound(teleporter, prelude.AUDIO_ASSETS["core/towerSfx/teleport"], "TeleportSound")
	end

	local config = prelude.tweenConfigFromAttributes(teleporter, "Transition")
	if not config.time or config.time == 0 then
		root:PivotTo(targetCFrame)
	else
		local wasAnchored = root.Anchored
		root.Anchored = true
		prelude.tween(root, { CFrame = targetCFrame }, config).Completed:Wait()
		root = prelude.getMaybeHumanoidRootPart()
		if root then
			root.Anchored = wasAnchored
			if KeepVelocity(teleporter) then
				root.AssemblyLinearVelocity = originalLinearVelocity
				root.AssemblyAngularVelocity = originalAngularVelocity
			end
		end
	end

	debounce = false
	prelude.Activatable:set(teleporter, true)
end

local self = {} :: std.KitScript
self.implements = { KitScript = true }

function self:run(kit: std.Kit)
	local Teleporter = kit:tag("Teleporter", prelude.isBasePart)
	local TeleporterDestination = kit:tag("TeleporterDestination", prelude.isBasePart)

	Teleporter:onActivated(teleport)

	TeleporterDestination:onLoaded(function(trove, destination)
		local id = TeleporterId(destination)
		if id then
			idToDestination:add(id, destination)
		end
		-- local previousId: string? = nil
		-- trove:connect(destination:GetAttributeChangedSignal(TeleporterId.name), function()
		-- 	local newId = TeleporterId(destination)
		-- 	if newId then
		-- 		if previousId ~= newId then
		-- 		    idToDestination:remove(previousId, destination)
		-- 		end
		-- 	elseif previousId then
		-- 	    idToDestination:remove(previousId, destination)
		-- 	end
		-- 	previousId = newId
		-- end)
		trove:add(function()
			local id = TeleporterId(destination)
			if id then
				idToDestination:remove(id, destination)
			end
		end)
	end)
end

return self
