local attributes = require("./attributes")
local character = require("./character")
local isFromMaybeCharacter = character.isFromMaybeCharacter
local t = require("./packages/t")

local SupportsCharacter = attributes.attribute("SupportsCharacter", t.boolean, false)
local SupportsBoxes = attributes.attribute("SupportsBoxes", t.boolean, false)
local BoxesRequiresMatchingId = attributes.attribute("BoxesRequiresMatchingId", t.boolean, false)
local RequiredBoxId = attributes.attribute("RequiredBoxId", t.string)

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
