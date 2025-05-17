local trove = require("./packages/trove")

--- @class KitStdPhysics
--- Physic utilities.

--- @within KitStdPhysics
--- Welds the `weldToTarget` to the `target`. Optionally unanchors the
--- `weldToTarget`.
local function weld(
	trove: trove.Trove,
	target: BasePart,
	weldToTarget: BasePart,
	unanchorTarget: boolean?
): WeldConstraint
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = weldToTarget
	weldConstraint.Part1 = target
	weldConstraint.Parent = weldToTarget

	if unanchorTarget then
		target.Anchored = false
	end

	return trove:add(weldConstraint)
end

--- @within KitStdPhysics
--- Creates 2 attachments and sets them to the constraint attachment properties.
local function populateConstraintAttachments(constraint: Constraint): (Attachment, Attachment)
	local attachment0 = Instance.new("Attachment")
	local attachment1 = Instance.new("Attachment")

	constraint.Attachment0 = attachment0
	constraint.Attachment1 = attachment1

	attachment0.Name = constraint.Name .. "Attachment0"
	attachment1.Name = constraint.Name .. "Attachment1"

	return attachment0, attachment1
end

local function intoCFrameOffset(offset: number | Vector3 | CFrame): CFrame
	if typeof(offset) == "number" then
		return CFrame.new(Vector3.yAxis * -offset)
	elseif typeof(offset) == "Vector3" then
		return CFrame.new(offset)
	elseif typeof(offset) == "CFrame" then
		return offset
	end
	error("exhausted")
end

return {
	weld = weld,
	populateConstraintAttachments = populateConstraintAttachments,
	intoCFrameOffset = intoCFrameOffset,
}
