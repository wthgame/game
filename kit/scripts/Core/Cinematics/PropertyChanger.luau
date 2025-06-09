--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local PropertyChanger = {}
type Self = typeof(PropertyChanger)
PropertyChanger.implements = { KitScript = true }

PropertyChanger.Attribute = prelude.AttributeGroup("Attribute", prelude.t.any)
PropertyChanger.NilAttribute = prelude.AttributeGroup("NilAttribute", prelude.isBoolean)
PropertyChanger.Property = prelude.AttributeGroup("Property", prelude.t.any)
PropertyChanger.NilProperty = prelude.AttributeGroup("NilProperty", prelude.isBoolean)
PropertyChanger.Tag = prelude.AttributeGroup("Tag", prelude.isBoolean)

function PropertyChanger.changeProperties(self: Self, propertyChanger: Instance, target: Instance)
	local tweenConfig = prelude.tweenConfigFromAttributes(propertyChanger, "Transition")
	prelude.tweenMaybeInstant(target, self.Property(propertyChanger), tweenConfig)

	for property, keep in self.NilProperty(propertyChanger) do
		if not keep then
			(target :: any)[property] = nil
		end
	end

	for tag, keep in self.Tag(propertyChanger) do
		if keep then
			target:RemoveTag(tag)
		else
			target:AddTag(tag)
		end
	end

	-- TODO: support tweening attributes
	for attribute, value in self.Attribute(propertyChanger) do
		target:SetAttribute(attribute, value)
	end

	for attribute, keep in self.NilAttribute(propertyChanger) do
		if not keep then
			target:SetAttribute(attribute, nil)
		end
	end
end

function PropertyChanger.changeIfObjectValue(self: Self, propertyChanger: Instance, value: Instance)
	if value:IsA("ObjectValue") then
		local obj = value.Value
		if obj then
			self:changeProperties(propertyChanger, obj)
		end
	end
end

function PropertyChanger.run(self: Self, kit: std.Kit)
	kit:tag("PropertyChanger"):onActivated(function(trove, instance)
		self:changeIfObjectValue(instance, instance)
		for _, descendant in instance:GetDescendants() do
			self:changeIfObjectValue(instance, descendant)
		end
	end)
end

return PropertyChanger
