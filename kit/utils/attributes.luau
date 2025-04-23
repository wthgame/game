local t = require("./packages/t")

local function attribute<T>(attributeName: string, check: t.check<T>, defaultValue: T?)
	return function(instance: Instance): T
		local value = instance:GetAttribute(attributeName)
		if value == nil or (check and not check(value)) then
			instance:SetAttribute(attributeName, defaultValue)
			return defaultValue :: T
		end
		return value :: T
	end
end

local function getEnumFromString(enumLike: string | EnumItem, defaultValue: EnumItem): any
	if typeof(enumLike) == "EnumItem" and enumLike.EnumType == defaultValue.EnumType then
		return enumLike
	end
	local success: boolean, enum: EnumItem? = pcall(function()
		return (defaultValue.EnumType :: any)[enumLike]
	end)
	return if success then enum else defaultValue
end

return {
	attribute = attribute :: (<T>(attributeName: string, check: t.check<T>) -> (instance: Instance) -> T?) & (<T>(
		attributeName: string,
		check: t.check<T>,
		defaultValue: T
	) -> (instance: Instance) -> T),
	isActive = attribute("Active", t.boolean, false),
	getEnumFromString = getEnumFromString :: <T>(enumLike: string | EnumItem, defaultValue: T & EnumItem) -> T,
}
