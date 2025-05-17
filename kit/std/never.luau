--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

--- @within KitStd
--- Never returns.
---
--- This is most useful when preventing bugs relating to not properly matching
--- every value, ie:
---
--- ```luau
--- type Color = "red" | "blue" | "green"
--- local function setColor(color: Color)
--- 	if color == "red" then
--- 		-- red
--- 	elseif color == "blue" then
--- 		-- blue
--- 	else
--- 		-- TYPE ERROR! You forgot to match "green".
--- 		std.never(color)
--- 	end
--- end
--- ```
---
--- @param ... never -- Any value that should never exist.
--- @return never -- Will error if a value supposedly never meant to exist, well, exists.
local function never(...: never): never
	error("This codepath should not be reachable")
end

return never
