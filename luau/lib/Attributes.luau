--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Types = require(script.Parent.Types)

local Attributes = {}

-- TODO: troves
function Attributes.createAttributeReconciler<T>(
	check: Types.Typechecker,
	defaultValue: T,
	attributeName: string
): (instance: Instance) -> T
	local function reconciler(instance)
		local realValue = instance:GetAttribute(attributeName)

		if realValue == nil then
			return defaultValue
		end

		if not check(realValue) then
			return defaultValue
		end

		return realValue :: T
	end

	return reconciler
end

table.freeze(Attributes)
return Attributes
