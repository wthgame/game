-- --!strict

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local lib = require(ReplicatedStorage:WaitForChild("Lib"))

-- local COOLDOWN = 0.25
-- local DETECTION_DISTANCE = 2
-- local OFFSET = Vector3.new(0, 0, 1)

-- local self = {} :: lib.Mechanic
-- self.type = "Mechanic"
-- self.name = "ClimableWall"

-- local function getMoveVector(cframe: CFrame, moveDirection: Vector3): Vector3
-- 	local normalCFrame = cframe * CFrame.Angles(math.pi / -2, 0, 0)
-- 	-- local MoveDirection = Humanoid.MoveDirection
-- 	local relativeDirection = workspace.CurrentCamera.CFrame.Rotation:PointToObjectSpace(moveDirection)
-- 	relativeDirection = relativeDirection * Vector3.new(1, 0, -1)

-- 	if relativeDirection.Magnitude > 0 then
-- 		relativeDirection = relativeDirection.Unit
-- 	end

-- 	return normalCFrame.Rotation:PointToWorldSpace(relativeDirection)
-- end

-- function self.attach(wth)
-- 	-- local ClimablePart: lib.Entity<BasePart> =
-- 	-- 	wth.trackCollectionServiceTag("ClimablePart", lib.t.instanceIsA("BasePart"))

-- 	-- local lastClimbTime = os.clock()
-- 	-- local isClimbing = false

-- 	-- local attachment: Attachment
-- 	-- local antiGravity: LinearVelocity
-- 	-- local linear: LinearVelocity
-- 	-- local align: AlignOrientation

-- 	-- local function climb(raycastResults: RaycastResult, humanoid: Humanoid, root: BasePart, dt: number)
-- 	-- 	if isClimbing == false then
-- 	-- 		local root = lib.getHumanoidRootPart()
-- 	-- 		isClimbing = true

-- 	-- 		attachment = Instance.new("Attachment")
-- 	-- 		antiGravity = Instance.new("LinearVelocity")
-- 	-- 		antiGravity.Attachment0 = attachment
-- 	-- 		antiGravity.MaxForce = math.huge
-- 	-- 		antiGravity.VectorVelocity = Vector3.zero
-- 	-- 		antiGravity.Parent = attachment

-- 	-- 		align = Instance.new("AlignOrientation")
-- 	-- 		align.Attachment0 = attachment
-- 	-- 		align.Mode = Enum.OrientationAlignmentMode.OneAttachment
-- 	-- 		align.MaxTorque = math.huge
-- 	-- 		align.Responsiveness = math.huge

-- 	-- 		linear = Instance.new("LinearVelocity")
-- 	-- 		linear.MaxForce = math.huge
-- 	-- 		linear.Parent = attachment

-- 	-- 		attachment.Parent = root
-- 	-- 	end

-- 	-- 	local newRootCFrame = CFrame.new(raycastResults.Position, raycastResults.Position + raycastResults.Normal)
-- 	-- 		* CFrame.fromEulerAngles(0, math.rad(180), 0, Enum.RotationOrder.XYZ):ToWorldSpace(CFrame.new(OFFSET))

-- 	-- 	align.CFrame = CFrame.lookAt(newRootCFrame.Position, newRootCFrame.Position + raycastResults.Normal)
-- 	-- 		* CFrame.fromEulerAngles(0, math.rad(180), 0, Enum.RotationOrder.XYZ)
-- 	-- 	humanoid.PlatformStand = true
-- 	-- 	root.AssemblyLinearVelocity = Vector3.zero

-- 	-- 	local multiplier = dt * 60
-- 	-- 	local moveVector = getMoveVector(newRootCFrame, humanoid.MoveDirection)
-- 	-- 	local speed = humanoid.WalkSpeed * 4

-- 	-- 	root.CFrame = newRootCFrame:Lerp(newRootCFrame + moveVector * speed * dt, 0.2 * multiplier)
-- 	-- end

-- 	-- local function stopClimb()
-- 	-- 	local humanoid = lib.getMaybeHumanoid()
-- 	-- 	if humanoid then
-- 	-- 		humanoid.PlatformStand = false
-- 	-- 	end

-- 	-- 	if antiGravity then
-- 	-- 		antiGravity:Destroy()
-- 	-- 		antiGravity = nil :: any
-- 	-- 	end

-- 	-- 	if align then
-- 	-- 		align:Destroy()
-- 	-- 		align = nil :: any
-- 	-- 	end

-- 	-- 	if linear then
-- 	-- 		linear:Destroy()
-- 	-- 		linear = nil :: any
-- 	-- 	end

-- 	-- 	if attachment then
-- 	-- 		attachment:Destroy()
-- 	-- 		attachment = nil :: any
-- 	-- 	end

-- 	-- 	if isClimbing then
-- 	-- 		isClimbing = false
-- 	-- 		if humanoid then
-- 	-- 			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
-- 	-- 		end
-- 	-- 	end
-- 	-- end

-- 	-- local queryClimablePart = wth.world:query(ClimablePart):cached()

-- 	-- local filterDescendants: { Instance } = {}

-- 	-- local function updateFilterDescendants()
-- 	-- 	table.clear(filterDescendants)
-- 	-- 	for entity, part in queryClimablePart:iter() do
-- 	-- 		if part:IsA("BasePart") then
-- 	-- 			table.insert(filterDescendants, part)
-- 	-- 		end
-- 	-- 	end
-- 	-- end

-- 	-- local function raycast(dt: number)
-- 	-- 	local root = lib.getMaybeHumanoidRootPart()
-- 	-- 	if not root then
-- 	-- 		return
-- 	-- 	end

-- 	-- 	local humanoid = lib.getMaybeHumanoid()
-- 	-- 	if not humanoid then
-- 	-- 		return
-- 	-- 	end

-- 	-- 	local raycastParams = RaycastParams.new()
-- 	-- 	raycastParams.FilterType = Enum.RaycastFilterType.Include
-- 	-- 	raycastParams.FilterDescendantsInstances = filterDescendants

-- 	-- 	local raycastResult =
-- 	-- 		workspace:Raycast(root.CFrame.Position, root.CFrame.LookVector * DETECTION_DISTANCE, raycastParams)

-- 	-- 	if raycastResult ~= nil and os.clock() - lastClimbTime > COOLDOWN and humanoid.Jump == false then
-- 	-- 		climb(raycastResult, humanoid, root, dt)
-- 	-- 	else
-- 	-- 		stopClimb()
-- 	-- 	end
-- 	-- end

-- 	-- wth.pushSystems(updateFilterDescendants, raycast)
-- end

-- -- local function updateClimableParts()
-- -- local CastParams = RaycastParams.new()
-- -- CastParams.FilterType = Enum.RaycastFilterType.Include
-- -- CastParams.FilterDescendantsInstances = FilterDescendants

-- -- local Heartbeat = RunService.Heartbeat:Connect(function(DeltaTime)
-- -- 	local Results = workspace:Raycast(
-- -- 		HumanoidRootPart.CFrame.Position,
-- -- 		HumanoidRootPart.CFrame.LookVector * Configuration.DetectionDistance,
-- -- 		CastParams
-- -- 	)

-- -- 	if Results ~= nil and CheckCoolDown() and Humanoid.Jump == false then
-- -- 		BeginClimb(Results, DeltaTime)
-- -- 	else
-- -- 		EndClimb()
-- -- 	end
-- -- end)

-- -- script.Destroying:Connect(function()
-- -- 	Heartbeat:Disconnect()
-- -- 	CharacterAdded:Disconnect()

-- -- 	if AntiGravity then AntiGravity:Destroy() end
-- -- 	if AlignOrientation then AlignOrientation:Destroy() end
-- -- 	if LinearVelocity then LinearVelocity:Destroy() end
-- -- 	if Attachment then Attachment:Destroy() end
-- -- end)
-- -- end

-- -- local function climb(ray:RaycastResult, dt:number)
-- --        if isClimbing == false then
-- --            local root = lib.getHumanoidRootPart()
-- --            isClimbing = true

-- --            attachment = Instance.new("Attachment")
-- --            antiGravity = Instance.new("LinearVelocity")
-- --            antiGravity.Attachment0 = attachment
-- --            antiGravity.MaxForce = math.huge
-- --            antiGravity.VectorVelocity = Vector3.zero
-- --            antiGravity.Parent = attachment

-- --            align = Instance.new("AlignOrientation")
-- --            align.Attachment0 = attachment
-- --            align.Mode = Enum.OrientationAlignmentMode.OneAttachment
-- --            align.MaxTorque = math.huge
-- --            align.Responsiveness = math.huge

-- --            linear = Instance.new("LinearVelocity")
-- --            linear.MaxForce = math.huge
-- --            linear.Parent = attachment

-- --            attachment.Parent = root
-- --        end
-- -- end

-- return self

-- --[[

--  --    local function CheckCoolDown()
-- 	-- if os.clock() - LastClimbTime < Configuration.Cooldown then
-- 	-- 	return
-- 	-- end
-- 	-- return true
--  --    end
--     local function BeginClimb(Results:RaycastResult, Delta:number)
-- 	if IsClimbing == false then
-- 		IsClimbing = true
-- 		AnimationTrack:Play()

-- 		Attachment = Instance.new("Attachment", HumanoidRootPart)
-- 		AntiGravity = Instance.new("LinearVelocity", Attachment)
-- 		AntiGravity.Attachment0 = Attachment
-- 		AntiGravity.MaxForce = math.huge
-- 		AntiGravity.VectorVelocity = Vector3.zero

-- 		AlignOrientation = Instance.new("AlignOrientation", Attachment)
-- 		AlignOrientation.Attachment0 = Attachment
-- 		AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
-- 		AlignOrientation.MaxTorque = math.huge
-- 		AlignOrientation.Responsiveness = math.huge

-- 		LinearVelocity = Instance.new("LinearVelocity", Attachment)
-- 		LinearVelocity.Parent = Attachment
-- 		LinearVelocity.MaxForce = math.huge
-- 	end

-- 	HumanoidRootPart.CFrame = CFrame.new(Results.Position, Results.Position + Results.Normal)
-- 		* CFrame.fromEulerAngles(0, math.rad(180), 0):ToWorldSpace(CFrame.new(Configuration.OffsetVector))
-- 	AlignOrientation.CFrame = CFrame.lookAt(HumanoidRootPart.Position, HumanoidRootPart.Position + Results.Normal)
-- 		* CFrame.fromEulerAngles(0, math.rad(180), 0)
-- 	Humanoid.PlatformStand = true
-- 	HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero

-- 	local Multiplier = Delta * 60
-- 	local Calculated = HumanoidRootPart.CFrame
-- 	local MoveVector = GetMoveVector(Calculated)
-- 	local ClimbSpeed = Humanoid.WalkSpeed * 4

-- 	Calculated += MoveVector * ClimbSpeed * Delta
-- 	HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(Calculated, 0.2 * Multiplier)

-- 	AnimationTrack:AdjustSpeed(MoveVector.Magnitude * (Humanoid.WalkSpeed / 10))
--     end

--     local function EndClimb()
-- 	if CheckCoolDown() then
-- 		LastClimbTime = os.clock()
-- 		AnimationTrack:Stop()
-- 	end

-- 	if Humanoid then Humanoid.PlatformStand = false end
-- 	if AntiGravity then AntiGravity:Destroy() end
-- 	if AlignOrientation then AlignOrientation:Destroy() end
-- 	if LinearVelocity then LinearVelocity:Destroy() end
-- 	if Attachment then Attachment:Destroy() end

-- 	if IsClimbing then
-- 		IsClimbing = false
-- 		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
-- 	end
--     end

--     return function()
-- 	-- Code below is required if you're using this outside of Potentially Fire Pillars

-- 	local FilterDescendants = {}
-- 	for _, Part in ipairs(ClimableSurfacesFolder:GetChildren()) do
-- 		if Part.ClassName == "Part" then
-- 			table.insert(FilterDescendants, Part)
-- 		end
-- 	end

-- 	local CastParams = RaycastParams.new()
-- 	CastParams.FilterType = Enum.RaycastFilterType.Include
-- 	CastParams.FilterDescendantsInstances = FilterDescendants

-- 	local CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(NewCharacter:Model)
-- 		Character = NewCharacter
-- 		Humanoid = Character:WaitForChild("Humanoid")
-- 		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- 		Animator = Humanoid:WaitForChild("Animator")::Animator
-- 		AnimationTrack = Animator:LoadAnimation(Animation)

-- 		IsClimbing = false
-- 	end)

-- 	local Heartbeat = RunService.Heartbeat:Connect(function(DeltaTime)
-- 		local Results = workspace:Raycast(
-- 			HumanoidRootPart.CFrame.Position,
-- 			HumanoidRootPart.CFrame.LookVector * Configuration.DetectionDistance,
-- 			CastParams
-- 		)

-- 		if Results ~= nil and CheckCoolDown() and Humanoid.Jump == false then
-- 			BeginClimb(Results, DeltaTime)
-- 		else
-- 			EndClimb()
-- 		end
-- 	end)

-- 	script.Destroying:Connect(function()
-- 		Heartbeat:Disconnect()
-- 		CharacterAdded:Disconnect()

-- 		if AntiGravity then AntiGravity:Destroy() end
-- 		if AlignOrientation then AlignOrientation:Destroy() end
-- 		if LinearVelocity then LinearVelocity:Destroy() end
-- 		if Attachment then Attachment:Destroy() end
-- 	end)
--     end
-- ]]

return nil
