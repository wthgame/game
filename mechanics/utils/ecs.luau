--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ecs = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHShared"):WaitForChild("ecs"))
local jecs = require("./packages/jecs")

local world: jecs.World = ecs.world

local function collectSignal(event: RBXScriptSignal): (() -> (number, ...any), RBXScriptConnection)
	local storage = {}
	local mt = {}

	local iter = function()
		local n = #storage
		return function(): (number?, ...any)
			if n <= 0 then
				mt.__iter = nil
				return nil
			end

			n -= 1
			return n + 1, unpack(table.remove(storage, 1) :: any)
		end
	end

	local connection = event:Connect(function(...)
		table.insert(storage, { ... })
		mt.__iter = iter :: any
	end)

	setmetatable(storage, mt)
	return storage :: any, connection
end

return {
	world = world,
	collectSignal = collectSignal,
}
