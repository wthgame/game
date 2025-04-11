--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Types = require(script.Parent.Types)

type Self<T> = Types.InstanceAttributeReconciler<T> & {
	_connections: { RBXScriptConnection },
}

local function reconcile<T>(self: Self<T>, instance: Instance): T
	local realValue = instance:GetAttribute(self.attributeName)

	if realValue == nil then
		return self.defaultValue
	end

	if not self.check(realValue) then
		return self.defaultValue
	end

	return realValue :: T
end

local function destroy(self: Self<any>)
	for _, connection in self._connections do
		if connection.Connected then
			connection:Disconnect()
		end
	end
end

local function InstanceAttributeReconciler<T>(
	check: Types.Typechecker,
	defaultValue: T,
	attributeName: string
): Types.InstanceAttributeReconciler<T>
	return table.freeze({
		_connections = {},
		type = "InstanceAttributeReconciler",
		check = check,
		attributeName = attributeName,
		defaultValue = defaultValue,
		reconcile = reconcile,
		destroy = destroy,
	} :: any)
end

return InstanceAttributeReconciler
