local attributes = require("./attributes")
local SupportsCharacter = attributes.SupportsCharacter
local character = require("./character")
local isFromMaybeLocalCharacter = character.isFromMaybeLocalCharacter

local function isToucher(target: Instance, toucher: BasePart)
	if SupportsCharacter(target) and isFromMaybeLocalCharacter(toucher) then
		return true
	end

	return false
end

local function isToucherCharacter(target: Instance, toucher: BasePart)
	return SupportsCharacter(target) and isFromMaybeLocalCharacter(toucher)
end

return {
	isToucher = isToucher,
	isToucherCharacter = isToucherCharacter,
}
