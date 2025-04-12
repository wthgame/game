--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local types = require("./types")

local function createAttributeReconciler<T>(
	attributeName: string,
	check: types.Typechecker<T>,
	defaultValue: T
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

return {
	createAttributeReconciler = createAttributeReconciler,
}
