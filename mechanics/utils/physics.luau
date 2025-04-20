local trove = require("./packages/trove")

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

local function populateConstraintAttachments(constraint: Constraint): (Attachment, Attachment)
	local attachment0 = Instance.new("Attachment")
	local attachment1 = Instance.new("Attachment")

	constraint.Attachment0 = attachment0
	constraint.Attachment1 = attachment1

	attachment0.Name = constraint.Name .. "Attachment0"
	attachment1.Name = constraint.Name .. "Attachment1"

	return attachment0, attachment1
end

return {
	weld = weld,
	populateConstraintAttachments = populateConstraintAttachments,
}
