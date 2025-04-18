--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("Utils"))

local threadsWaitingColorUpdate: utils.Map<Color3, utils.Set<thread>> = {}

local function updateColor(color: Color3)
	for setColor, threads in threadsWaitingColorUpdate do
		if setColor == color then
			for thread in threads do
				task.spawn(thread, color)
			end
			table.clear(threads)
			threadsWaitingColorUpdate[setColor] = nil

			-- NOTE: we don't break early because identical Color3s may be
			-- unique, try printing a Color3.new() to see if it's the same
		end
	end
end

local function spawnOnceColorUpdated(color: Color3, fn: () -> ())
	local waitingThreads: utils.Set<thread> = threadsWaitingColorUpdate[color]
	if not waitingThreads then
		waitingThreads = {}
		threadsWaitingColorUpdate[color] = waitingThreads
	end

	waitingThreads[coroutine.create(fn)] = true
end

return {
	updateColor = updateColor,
	spawnOnceColorUpdated = spawnOnceColorUpdated,
}
