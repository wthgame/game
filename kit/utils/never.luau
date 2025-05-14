--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

--- Never returns.
local function never(): never
	error("This codepath should not be reachable")
end

return never
