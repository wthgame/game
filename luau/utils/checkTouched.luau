local Players = game:GetService("Players")

local types = require(script.Parent.types)

--- Returns true if a touching part passes the config, which can filter the
--- following:
---
--- * Pass all player characters
--- * Pass only the local player's characters
local function checkTouched(toucher: BasePart, config: types.TouchConfig): boolean
	if config.passAllPlayerCharacters or config.passLocalPlayerCharacters then
		local character = toucher.Parent
		if character then
			local playerTouched = Players:GetPlayerFromCharacter(character :: Model)
			if
				config.passAllPlayerCharacters and playerTouched
				or config.passLocalPlayerCharacters and playerTouched == Players.LocalPlayer
			then
				return true
			end
		end
	end

	return false
end

return checkTouched
