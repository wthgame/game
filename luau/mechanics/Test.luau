--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type TestAttributes = {
	Flash: boolean,
}

return utils.createMechanic("Test", function(wth)
	local Test: utils.Entity<BasePart> = wth.createMechanicTag("Test", utils.t.instanceIsA("BasePart"))

	local TestAttributes: utils.Entity<TestAttributes> = wth.createMechanicAttributes(Test, {
		Flash = utils.t.boolean,
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
end)
