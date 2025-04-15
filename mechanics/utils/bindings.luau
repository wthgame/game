local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Bindings = {
	addMechanicBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> (),
	callMechanicBinding: (key: unknown, ...unknown) -> (),
}

local bindings = require(
	ReplicatedStorage:WaitForChild("WTHClient")
		:WaitForChild("controllers")
		:WaitForChild("mechanics")
		:WaitForChild("bindings")
)

local function promptToLoadTower(name: string)
	bindings.callMechanicBinding("TowersController.promptToLoadTower", name)
end

return {
	promptToLoadTower = promptToLoadTower,

	addMechanicBinding = bindings.addMechanicBinding,
	callMechanicBinding = bindings.callMechanicBinding,
}
