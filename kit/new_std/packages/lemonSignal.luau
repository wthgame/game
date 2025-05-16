--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local LemonSignal = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("WTHSharedCore")
		:WaitForChild("include")
		:WaitForChild("node_modules")
		:WaitForChild("@rbxts")
		:WaitForChild("lemon-signal")
		:WaitForChild("src")
)

export type Connection<U...> = LemonSignal.Connection<U...>
export type Signal<T...> = LemonSignal.Signal<T...>

return LemonSignal
