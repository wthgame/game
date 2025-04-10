--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TeleporterAttributes = {
	KeepVelocity: boolean,
	DisableCollision: boolean,
	SeamlessTeleport: boolean,
	RemoveButtons: boolean,
	TransitionTime: number,
	EasingStyle: string,
	EasingDirection: string,
	CooldownSeconds: number,

	PassLocalPlayerCharacter: boolean,
	PassPushboxes: boolean,
}

type TeleporterInstance = BasePart

local self = {} :: utils.Mechanic<TeleporterAttributes, TeleporterInstance>
self.type = "Mechanic"
self.name = "Teleporter"

self.attributes = {
	KeepVelocity = utils.t.boolean,
	DisableCollision = utils.t.boolean,
	SeamlessTeleport = utils.t.boolean,
	RemoveButtons = utils.t.boolean,
	TransitionTime = utils.t.number,
	-- TODO: more precise types?
	EasingStyle = utils.t.string,
	EasingDirection = utils.t.string,
	CooldownSeconds = utils.t.number,

	PassLocalPlayerCharacter = utils.t.boolean,
	PassPushboxes = utils.t.boolean,
}

self.defaultAttributes = {
	KeepVelocity = true,
	DisableCollision = false,
	SeamlessTeleport = false,
	RemoveButtons = false,
	TransitionTime = 0,
	EasingStyle = "Quad",
	EasingDirection = "Out",
	CooldownSeconds = 0.5,

	PassLocalPlayerCharacter = true,
	PassPushboxes = true,
}

self.instanceCheck = utils.t.instanceIsA("BasePart")

function self:mechanize(ctx)
	local teleportingParts: { [BasePart]: boolean } = {}
	local teleporterCooldowns: { [BasePart]: boolean } = {}

	local function teleport(object: BasePart, teleporterPart: BasePart, destination: BasePart, isPlayer: boolean)
		local camera: Camera = workspace.CurrentCamera

		if teleporterCooldowns[teleporterPart] or teleportingParts[object] then
			return
		end
		teleportingParts[object] = true
		teleporterCooldowns[teleporterPart] = true
		local cooldown = ctx.getAttribute("Cooldown")
		if cooldown > 0 then
			task.delay(cooldown, function()
				teleporterCooldowns[teleporterPart] = false
			end)
		else
			task.defer(function()
				teleporterCooldowns[teleporterPart] = false
			end)
		end

		local savedPartProperties: { [BasePart]: any } = { [object] = { Anchored = object.Anchored } }
		if not ctx.getAttribute("KeepVelocity") then
			object.AssemblyLinearVelocity = Vector3.zero
			object.AssemblyAngularVelocity = Vector3.zero
			savedPartProperties[object].AssemblyLinearVelocity = Vector3.zero
			savedPartProperties[object].AssemblyAngularVelocity = Vector3.zero
		end

		if ctx.getAttribute("DisableCollision") then
			local character = utils.getMaybeCharacter()
			local parts = { object }
			if isPlayer and character then
				for _, part in character:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end
					if table.find(parts, part) then
						continue
					end
					table.insert(parts, part)
				end
			end

			for _, part in parts do
				if not savedPartProperties[part] then
					savedPartProperties[part] = {}
				end

				savedPartProperties[part].CollisionGroup = part.CollisionGroup
				savedPartProperties[part].CanTouch = part.CanTouch
				part.CollisionGroup = "NeverCollide"
				part.CanTouch = false
			end
		end

		local targetCFrame = destination.CFrame * CFrame.new(Vector3.yAxis * 5)
		if ctx.getAttribute("SeamlessTeleport") then
			targetCFrame = destination.CFrame * teleporterPart.CFrame:ToObjectSpace(object.CFrame)
			if isPlayer then
				camera.CFrame = destination.CFrame * teleporterPart.CFrame:ToObjectSpace(camera.CFrame)
			end
		end

		-- utility.playSoundFromPart("TeleportSound", destination, destination)
		-- local transitionTime = ctx.getAttribute("TransitionTime")
		-- if transitionTime > 0 then
		-- 	object.Anchored = true
		-- 	-- utility
		-- 	-- 	.tween(object, transitionTime, { CFrame = targetCFrame }, easingStyle, easingDirection).Completed
		-- 	-- 	:Wait()
		-- 	object.CFrame = targetCFrame
		-- else
		object.CFrame = targetCFrame
		-- end

		for part, properties in savedPartProperties do
			for property, value in properties do
				(part :: any)[property] = value
			end
		end

		teleportingParts[object] = nil
	end

	local destinations: { BasePart } = {}
	local function getActiveDestinations(): { BasePart }
		local activeDestinations = {}
		for _, destination in destinations do
			if ctx.instance:GetAttribute("Activated") == false then
				continue
			end
			table.insert(activeDestinations, destination)
		end

		return activeDestinations
	end

	-- local innerScope = ctx.pushTasks({})
	-- -- todo: docleanup
	-- -- ctx.instance.Destroying:Connect(callback)
	-- -- currentTrove:AttachToInstance(teleporter)

	-- for _, object: Instance in ctx.instance:GetDescendants() do
	-- 	if not object:IsA("BasePart") then
	-- 		continue
	-- 	end

	-- 	if object.Name == "Destination" then
	-- 		table.insert(destinations, object)
	-- 	end
	-- 	if object.Name == "Teleporter" then
	-- 		ctx:pushTasks(object.Touched, function(touchingPart: BasePart)
	-- 			if teleporterCooldowns[object] then
	-- 				return
	-- 			end
	-- 			if table.find(PART_BLACKLIST, touchingPart.Name) then
	-- 				return
	-- 			end
	-- 			if not utils.checkTouched(object, touchingPart, configuration, ALLOWED_EVALUATION_CHECKS) then
	-- 				return
	-- 			end
	-- 			if utility.checkConfig(object, "Activated") == false then
	-- 				return
	-- 			end

	-- 			local currentDestinations = getActiveDestinations()
	-- 			if #currentDestinations <= 0 then
	-- 				return
	-- 			end

	-- 			local destination = currentDestinations[Random.new():NextInteger(1, #currentDestinations)]
	-- 			if removeButtons and shared.button_cache ~= nil then
	-- 				for _, button in shared.button_cache.Buttons do
	-- 					button.Pressed.Value = false
	-- 				end
	-- 			end

	-- 			local character: Model? = localPlayer.Character
	-- 			if character and character.PrimaryPart and touchingPart.Parent == character then
	-- 				teleport(character.PrimaryPart, object, destination, true)
	-- 			elseif utility.isPushbox(touchingPart) then
	-- 				teleport(touchingPart, object, destination, false)
	-- 			end
	-- 		end)
	-- 	end
	-- end
end

return self
