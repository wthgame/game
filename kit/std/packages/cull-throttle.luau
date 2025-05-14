--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local CullThrottle = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("WTHSharedCore")
		:WaitForChild("include")
		:WaitForChild("node_modules")
		:WaitForChild("@rbxts")
		:WaitForChild("cullthrottle")
		:WaitForChild("src")
)

export type CullThrottle = CullThrottle.CullThrottle

return CullThrottle
