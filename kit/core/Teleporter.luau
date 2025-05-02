--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local TeleporterId = utils.attribute("TeleporterId", utils.isString)
local KeepVelocity = utils.attribute("KeepVelocity", utils.isBoolean, true)
local Cooldown = utils.attribute("Cooldown", utils.isPositiveNumber, 0)
local PlaySound = utils.attribute("PlaySound", utils.isBoolean, true)
local TeleporterOffset = utils.attribute(
	"TeleportOffset",
	utils.t.union(utils.t.number, utils.t.Vector3, utils.t.CFrame),
	Vector3.new(0, 3, 0)
)

-- NOTE: using MapArray to use random teleporter destinations
local idToDestination: utils.MapArray<string, BasePart> = utils.MapArray()
local debounce = false
local debouncedTeleporters: utils.Set<BasePart> = {}

local function teleport(trove: utils.Trove, teleporter: BasePart)
	local root = utils.getMaybeHumanoidRootPart()
	if not root then
		return
	end

	if debounce or debouncedTeleporters[teleporter] then
		return
	end

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

	local targetCFrame = targetDestination:GetPivot() * utils.intoCFrameOffset(TeleporterOffset(targetDestination))

	if PlaySound(teleporter) then
		utils.inferAndPlaySound(teleporter, utils.SOUND_ASSETS.teleport, "TeleportSound")
	end

	local config = utils.tweenConfigFromAttributes(teleporter, "Transition")
	if not config.time or config.time == 0 then
		root:PivotTo(targetCFrame)
	else
		local wasAnchored = root.Anchored
		root.Anchored = true
		utils.tween(root, { CFrame = targetCFrame }, config).Completed:Wait()
		root = utils.getMaybeHumanoidRootPart()
		if root then
			root.Anchored = wasAnchored
			if KeepVelocity(teleporter) then
				root.AssemblyLinearVelocity = originalLinearVelocity
				root.AssemblyAngularVelocity = originalAngularVelocity
			end
		end
	end

	debounce = false
end

local self = {} :: utils.KitScript
self.type = "KitScript"

function self:run(kit: utils.Kit)
	local Teleporter = kit:tag("Teleporter", utils.isBasePart)
	local TeleporterDestination = kit:tag("TeleporterDestination", utils.isBasePart)

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
