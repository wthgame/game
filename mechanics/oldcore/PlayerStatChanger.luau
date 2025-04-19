-- --!strict

-- -- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local utils = require(ReplicatedStorage:WaitForChild("Utils"))

-- type Mode = "Boost" | "Zone" | "Reset"
-- type PlayerStat = "Walkspeed" | "JumpPower"

-- local RING_OF_FIRE_TWEEN_CONFIG: utils.TweenConfig = {
-- 	time = 0.5,
-- 	easingStyle = Enum.EasingStyle.Circular,
-- }

-- local RING_OF_FIRE_DECAL_TWEEN_CONFIG: utils.TweenConfig = {
-- 	time = 0.5,
-- 	easingStyle = Enum.EasingStyle.Circular,
-- 	reverse = true,
-- }

-- local mech = {} :: utils.Mechanic
-- mech.type = "Mechanic"
-- mech.name = "PlayerStatChanger"

-- local function createRingOfFire(trove: utils.Trove, part: BasePart)
-- 	local initialSize = Vector3.new(part.Size.X, 0, part.Size.Z)

-- 	local ringOfFire = trove:add(Instance.new("Part"))
-- 	ringOfFire.Name = "RingOfFire"
-- 	ringOfFire.Anchored = true
-- 	ringOfFire.CanCollide = false
-- 	ringOfFire.Transparency = 1
-- 	ringOfFire.Size = initialSize
-- 	ringOfFire.CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2, 0)

-- 	local gui = trove:add(Instance.new("SurfaceGui"))
-- 	gui.Adornee = ringOfFire
-- 	gui.Face = Enum.NormalId.Top
-- 	gui.LightInfluence = 0
-- 	gui.Brightness = 5

-- 	local image = trove:add(Instance.new("ImageLabel"))
-- 	image.BackgroundTransparency = 1
-- 	image.Size = UDim2.fromScale(1, 1)
-- 	image.Image = "rbxassetid://46884626"
-- 	image.Parent = gui

-- 	gui.Parent = ringOfFire

-- 	ringOfFire.Parent = part

-- 	local ringTween = trove:add(utils.tween(ringOfFire, RING_OF_FIRE_TWEEN_CONFIG, {
-- 		Size = initialSize * 2,
-- 		CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 2 + 1, 0) * CFrame.Angles(0, math.rad(90), 0),
-- 	}))

-- 	trove:add(utils.tween(image, RING_OF_FIRE_DECAL_TWEEN_CONFIG, {
-- 		ImageTransparency = 1,
-- 	}))

-- 	trove:add(ringTween.Completed:Once(function()
-- 		image:Destroy()
-- 		gui:Destroy()
-- 		ringOfFire:Destroy()
-- 	end))
-- end

-- function mech:init(wth)
-- 	local PlayerStatChanger: utils.Entity<BasePart> = wth:useTag("PlayerStatChanger", utils.t.instanceIsA("BasePart"))

-- 	-- stylua: ignore start
-- 	local Enabled = wth:useAttribute("Enabled", PlayerStatChanger, utils.t.boolean, true)
-- 	local Mode: utils.Entity<Mode> = wth:useAttribute("Mode", PlayerStatChanger, utils.t.literal("Boost", "Zone", "Reset") :: any, "Boost")
-- 	local PlayerStat: utils.Entity<PlayerStat> = wth:useAttribute("PlayerStat", PlayerStatChanger, utils.t.literal("Walkspeed", "JumpPower") :: any, "Walkspeed")
-- 	local Value = wth:useAttribute("Value", PlayerStatChanger, utils.t.numberPositive, 0)
-- 	local Duration = wth:useAttribute("Duration", PlayerStatChanger, utils.t.numberPositive, 0)
-- 	local Cooldown = wth:useAttribute("Cooldown", PlayerStatChanger, utils.t.numberPositive, 0)
-- 	-- stylua: ignore end

-- 	local Active: utils.Entity = wth.world:component()

-- 	local queryPlayerStatChanger = wth.world
-- 		:query(PlayerStatChanger, Enabled, Mode, PlayerStat, Value, Duration, Cooldown)
-- 		:without(Active)
-- 		:cached()

-- 	-- local function applyPlayerStats()
-- 	-- 	local humanoid = utils.getMaybeHumanoid()
-- 	-- 	if not humanoid then
-- 	-- 		return
-- 	-- 	end

-- 	-- 	humanoid.WalkSpeed = 16
-- 	-- 	humanoid.JumpPower = 100

-- 	-- 	for _, entity in statBuffer do
-- 	-- 		local stat: PlayerStat? = wth.world:get(entity, PlayerStat) :: any
-- 	-- 		local value = wth.world:get(entity, Value)

-- 	-- 		if stat and value then
-- 	-- 			if stat == "Walkspeed" then
-- 	-- 				humanoid.WalkSpeed = value
-- 	-- 			elseif stat == "JumpPower" then
-- 	-- 				humanoid.JumpPower = value
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end

-- 	local function checkPlayerStatChangers(_, trove: utils.Trove)
-- 		local humanoid = utils.getMaybeHumanoid()
-- 		if not humanoid then
-- 			return
-- 		end

-- 		for entity, changer, enabled, mode, stat, value, duration, cooldown in queryPlayerStatChanger:iter() do
-- 			if not enabled then
-- 				continue
-- 			end

-- 			if not utils.isLocalPlayerCharacterTouchingPart(changer) then
-- 				continue
-- 			end

-- 			wth.world:add(entity, Active)
-- 			createRingOfFire(trove, changer)

-- 			local original
-- 			if mode == "Walkspeed" then
-- 				original = humanoid.WalkSpeed
-- 				humanoid.WalkSpeed = value
-- 			end

-- 			task.delay(duration, function(entity)
-- 				if mode == "Walkspeed" then
-- 					humanoid.WalkSpeed = original
-- 				end
-- 			end, entity)

-- 			task.delay(duration + cooldown, function(entity)
-- 				wth.world:remove(entity, Active)
-- 			end, entity)
-- 		end
-- 	end

-- 	wth:schedule(checkPlayerStatChangers)
-- end

-- return mech
return nil
