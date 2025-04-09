--!strict
--!nolint LocalShadow

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING
-- NOTE: based on https://github.com/tenx29/PartEmitter/blob/master/src/PartEmitter.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Particle = {
	when: number,
	attachment0: Attachment,
	attachment1: Attachment,
	beam: Beam,
	speed: number,
	lifetimeSeconds: number,
	startingRotation: number,
	rotationSpeed: number,
	startingCFrame: CFrame,
}

type EmissionDirection = "Top" | "Bottom" | "Left" | "Right" | "Front" | "Back"

local EmissionDirection = utils.t.literalList({
	"Top",
	"Bottom",
	"Left",
	"Right",
	"Front",
	"Back",
})

type Orientation = "FacingCamera" | "FacingCameraWorldUp" | "VelocityParallel" | "VelocityPerpendicular"

local Orientation = utils.t.literalList({
	"FacingCamera",
	"FacingCameraWorldUp",
	"VelocityParallel",
	"VelocityPerpendicular",
})

type Shape = "Box"

local Shape = utils.t.literalList({
	"Shape",
})

type ShapeInOut = "In" | "Out" | "InOut"

local ShapeInOut = utils.t.literalList({
	"In",
	"Out",
	"InOut",
})

type ShapeKind = "Volume" | "Surface"

local ShapeKind = utils.t.literalList({
	"Volume",
	"Surface",
})

type OptimizationStrategy = "None" | "FreezeWhenObscured" | "DisableWhenObscured"

local OptimizationStrategy = utils.t.literalList({
	"None",
	"FreezeWhenObscured",
	"DisableWhenObscured",
})

type ParticlePartEmitterAttributes = {
	Acceleration: Vector3,
	Brightness: number,
	Color: ColorSequence,
	EmissionDirection: EmissionDirection,
	Enabled: boolean,
	Image: string,
	LifetimeSeconds: NumberRange,
	LightEmission: number,
	LightInfluence: number,
	Orientation: Orientation,
	-- TODO: implement
	OptimizationStrategy: OptimizationStrategy,
	Rate: number,
	Rotation: NumberRange,
	RotationSpeed: NumberRange,
	Size: NumberSequence,
	Shape: Shape,
	ShapeInOut: ShapeInOut,
	ShapeKind: ShapeKind,
	Speed: NumberRange,
	Squash: NumberSequence,
	Transparency: NumberSequence,
	ZOffset: number,
}

type ParticlePartEmitterInstance = BasePart

local self = {} :: utils.Mechanic<ParticlePartEmitterAttributes, ParticlePartEmitterInstance>
self.type = "Mechanic"
self.name = "ParticlePartEmitter"

self.attributes = {
	Acceleration = utils.t.Vector3,
	Brightness = utils.t.numberPositive,
	Color = utils.t.ColorSequence,
	EmissionDirection = EmissionDirection,
	Enabled = utils.t.boolean,
	Image = utils.t.string,
	LifetimeSeconds = utils.t.NumberRange,
	LightEmission = utils.t.numberConstrained(0, 1),
	LightInfluence = utils.t.numberConstrained(0, 1),
	Orientation = Orientation,
	OptimizationStrategy = OptimizationStrategy,
	Rate = utils.t.numberPositive,
	Rotation = utils.t.NumberRange,
	RotationSpeed = utils.t.NumberRange,
	Size = utils.t.NumberSequence,
	Shape = Shape,
	ShapeInOut = ShapeInOut,
	ShapeKind = ShapeKind,
	Speed = utils.t.NumberRange,
	Squash = utils.t.NumberSequence,
	Transparency = utils.t.NumberSequence,
	ZOffset = utils.t.numberPositive,
}

self.defaultAttributes = {
	Acceleration = Vector3.new(0, 0, 0),
	Brightness = 1,
	Color = ColorSequence.new(Color3.new(1, 1, 1)),
	EmissionDirection = "Top",
	Enabled = true,
	Image = "rbxasset://textures/particles/sparkles_main.dds",
	LifetimeSeconds = NumberRange.new(5, 10),
	LightEmission = 0,
	LightInfluence = 1,
	Orientation = "FacingCamera",
	OptimizationStrategy = "None",
	Rate = 20,
	Rotation = NumberRange.new(0, 0),
	RotationSpeed = NumberRange.new(0, 0),
	Size = NumberSequence.new(1),
	Shape = "Box",
	ShapeInOut = "In",
	ShapeKind = "Volume",
	Speed = NumberRange.new(5, 5),
	Squash = NumberSequence.new(0),
	Transparency = NumberSequence.new(0),
	ZOffset = 0,
}

self.instanceCheck = utils.t.instanceIsA("BasePart")

local function evaluateNumberSequence(ns: NumberSequence, time: number): number
	if time <= 0 then
		return ns.Keypoints[1].Value
	end

	if time >= 1 then
		return ns.Keypoints[#ns.Keypoints].Value
	end

	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if time >= this.Time and time < next.Time then
			local alpha = (time - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end

	error("unreachable")
end

local function evaluateColorSequence(sequence: ColorSequence, time: number)
	-- If time is 0 or 1, return the first or last value respectively
	if time == 0 then
		return sequence.Keypoints[1].Value
	elseif time == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	-- Otherwise, step through each sequential pair of keypoints
	for i = 1, #sequence.Keypoints - 1 do
		local thisKeypoint = sequence.Keypoints[i]
		local nextKeypoint = sequence.Keypoints[i + 1]
		if time >= thisKeypoint.Time and time < nextKeypoint.Time then
			-- Calculate how far alpha lies between the points
			local alpha = (time - thisKeypoint.Time) / (nextKeypoint.Time - thisKeypoint.Time)
			-- Evaluate the real value between the points using alpha
			return Color3.new(
				(nextKeypoint.Value.R - thisKeypoint.Value.R) * alpha + thisKeypoint.Value.R,
				(nextKeypoint.Value.G - thisKeypoint.Value.G) * alpha + thisKeypoint.Value.G,
				(nextKeypoint.Value.B - thisKeypoint.Value.B) * alpha + thisKeypoint.Value.B
			)
		end
	end

	error("unreachable")
end

local function calculateUDim2ScaleFromSquash(squash: number): UDim2
	-- TODO: implement
	return UDim2.fromScale(1, 1)
end

-- shit is not working
function self:mechanize(ctx)
	-- local instance = ctx.instance
	-- local lastEmission = os.clock()
	-- local random = Random.new(os.time())
	-- local particles: { [Particle]: true } = {}

	-- local function emit(amount: number?)
	-- 	local amount = amount or 1

	-- 	local attributes = ctx.getAllAttributes()

	-- 	local lifetimeSeconds = attributes.LifetimeSeconds
	-- 	local speed = attributes.Speed
	-- 	local rotation = attributes.Rotation
	-- 	local rotationSpeed = attributes.RotationSpeed

	-- 	for index = 1, amount do
	-- 		local now = os.clock()

	-- 		local attachment0 = ctx.trove:add(Instance.new("Attachment"))
	-- 		attachment0.Parent = instance

	-- 		local attachment1 = ctx.trove:add(Instance.new("Attachment"))
	-- 		attachment1.Parent = instance

	-- 		ctx.trove:add(Instance.new("ParticleEmitter", attachment0)).Speed = NumberRange.new(0)
	-- 		ctx.trove:add(Instance.new("ParticleEmitter", attachment1)).Speed = NumberRange.new(0)

	-- 		local beam = ctx.trove:add(Instance.new("Beam"))
	-- 		beam.Attachment0 = attachment0
	-- 		beam.Attachment1 = attachment1
	-- 		beam.Width0 = 1
	-- 		beam.Width1 = 1
	-- 		beam.Texture = attributes.Image
	-- 		beam.Color = ColorSequence.new(evaluateColorSequence(attributes.Color, 0))
	-- 		beam.Parent = instance
	-- 		beam.FaceCamera = true
	-- 		beam.Segments = 1

	-- 		local particle: Particle = {
	-- 			when = now,
	-- 			attachment0 = attachment0,
	-- 			attachment1 = attachment1,
	-- 			beam = beam,
	-- 			speed = random:NextNumber(speed.Min, speed.Max),
	-- 			lifetimeSeconds = random:NextNumber(lifetimeSeconds.Min, lifetimeSeconds.Max),
	-- 			startingRotation = random:NextNumber(rotation.Min, rotation.Max),
	-- 			rotationSpeed = random:NextNumber(rotationSpeed.Min, rotationSpeed.Max),
	-- 			startingCFrame = CFrame.new(),
	-- 		}

	-- 		particles[particle] = true
	-- 	end
	-- end

	-- local function destroyParticle(particle: Particle)
	-- 	particles[particle] = nil
	-- 	particle.attachment0:Destroy()
	-- 	particle.attachment1:Destroy()
	-- 	particle.beam:Destroy()
	-- end

	-- ctx.trove:add(RunService.PreRender:Connect(function()
	-- 	debug.profilebegin("ParticlePartEmitter")
	-- 	local now = os.clock()
	-- 	local rate = ctx.getAttribute("Rate")
	-- 	if ctx.getAttribute("Enabled") and now - lastEmission >= 1 / rate then
	-- 		local emitCount = math.floor(rate * (now - lastEmission))
	-- 		if emitCount > 0 then
	-- 			emit(emitCount)
	-- 			lastEmission = now
	-- 		end
	-- 	end

	-- 	-- local bulkMoveParts, bulkMoveCFrames = {}, {}

	-- 	for particle in particles do
	-- 		local elapsedSeconds = os.clock() - particle.when
	-- 		if elapsedSeconds >= particle.lifetimeSeconds then
	-- 			destroyParticle(particle)
	-- 			continue
	-- 		end

	-- 		-- local progress = elapsedSeconds / particle.lifetimeSeconds
	-- 		-- TODO: account normals
	-- 		local speed = Vector3.new(0, particle.speed * elapsedSeconds, 0)

	-- 		local center = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, speed)
	-- 		particle.attachment0.CFrame = CFrame.new(0, 0.5, 0):ToObjectSpace(center)
	-- 		particle.attachment1.CFrame = CFrame.new(0, -0.5, 0):ToObjectSpace(center)

	-- 		-- particle.part.CFrame = CFrame.lookAt(workspace.CurrentCamera, particle.startingCFrame * speed)

	-- 		-- table.insert(bulkMoveParts, particle.part)
	-- 		-- table.insert(bulkMoveCFrames, particle.startingCFrame + speed)
	-- 	end

	-- 	-- workspace:BulkMoveTo(bulkMoveParts, bulkMoveCFrames)
	-- 	debug.profileend()
	-- end))

	-- print(ctx)

	-- print(ctx.getAllAttributes())
end

return self
