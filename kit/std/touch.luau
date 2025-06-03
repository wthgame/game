local attributes = require("./attributes")
local character = require("./character")
local isFromMaybeCharacter = character.isFromMaybeCharacter
local t = require("./packages/t")

local SupportsCharacter = attributes.Attribute("SupportsCharacter", t.boolean, false)
local SupportsBoxes = attributes.Attribute("SupportsBoxes", t.boolean, false)
local BoxesRequiresMatchingId = attributes.Attribute("BoxesRequiresMatchingId", t.boolean, false)
local RequiredBoxId = attributes.Attribute("RequiredBoxId", t.string)

local function isToucherValid(target: Instance, toucher: BasePart)
	if SupportsCharacter(target) and isFromMaybeCharacter(toucher) then
		return true
	end

	return false
end

local function isToucherCharacter(target: Instance, toucher: BasePart)
	return SupportsCharacter(target) and isFromMaybeCharacter(toucher)
end

return {
	isToucherValid = isToucherValid,
	isToucherCharacter = isToucherCharacter,
	SupportsCharacter = SupportsCharacter,
	SupportsBoxes = SupportsBoxes,
	BoxesRequiresMatchingId = BoxesRequiresMatchingId,
	RequiredBoxId = RequiredBoxId,
}
