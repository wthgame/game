local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type Test = utils.MechanicComponent<{}, Instance>

return utils.createMechanic("Test", function(wth)
	local Test: Test = wth.createMechanicComponent({
		tag = "Test",
		defaultAttributes = {},
		attributeChecks = {},
		instanceCheck = utils.t.Instance,
	}) :: any

	local queryTest = wth.world:query(Test):cached()

	local function updateTest()
		for entity, test in queryTest:iter() do
			print(test.instance)
		end
	end

	wth.pushSystems(updateTest)
end)
