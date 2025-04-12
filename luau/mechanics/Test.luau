--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage:WaitForChild("Lib"))

type TestAttributes = {
	Flash: boolean,
}

local self = {} :: lib.Mechanic
self.type = "Mechanic"
self.name = "Test"

function self.attach(wth)
	local Test: lib.Entity<BasePart> = wth.trackCollectionServiceTag("Test", lib.t.instanceIsA("BasePart"))

	local TestAttributes: lib.Entity<TestAttributes> = wth.createMechanicAttributes(Test, {
		Flash = lib.t.boolean,
	}, {
		Flash = true,
	})

	local queryTest = wth.world:query(Test):cached()

	local function updateTest()
		for entity, test in queryTest:iter() do
			local attributes = wth.world:get(entity, TestAttributes)
			if attributes and attributes.Flash then
				test.Color = Color3.new(math.random(), math.random(), math.random())
			end
		end
	end

	wth.pushSystems(updateTest)
end

return self
