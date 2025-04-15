local function createRingOfFire()
	local ringOfFire = Instance.new("ParticleEmitter")

	ringOfFire.Name = "RingOfFire"
	ringOfFire.Brightness = 5
	ringOfFire.Lifetime = NumberRange.new(0.5)
	ringOfFire.LockedToPart = true
	ringOfFire.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
	ringOfFire.Rate = 1
	ringOfFire.RotSpeed = NumberRange.new(720)
	ringOfFire.Shape = Enum.ParticleEmitterShape.Sphere
	ringOfFire.ShapePartial = 0
	ringOfFire.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	ringOfFire.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 6),
		NumberSequenceKeypoint.new(1, 10),
	})
	ringOfFire.Speed = NumberRange.new(2)
	ringOfFire.Texture = "rbxassetid://46884626"
	ringOfFire.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0),
		NumberSequenceKeypoint.new(1, 1),
	})

	return ringOfFire
end

return {
	createRingOfFire = createRingOfFire,
}
