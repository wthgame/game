local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Bindings = {
	addMechanicBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> (),
	callMechanicBinding: (key: unknown, ...unknown) -> (),
}

local bindings = require(
	ReplicatedStorage:WaitForChild("WTHClient")
		:WaitForChild("controllers")
		:WaitForChild("MechanicController")
		:WaitForChild("bindings")
) :: Bindings

local function promptToStartNewTowerRun(name: string)
	bindings.callMechanicBinding("TowerRunController.promptToStartNewTowerRun", name)
end

return {
	promptToStartNewTowerRun = promptToStartNewTowerRun,

	addMechanicBinding = bindings.addMechanicBinding,
	callMechanicBinding = bindings.callMechanicBinding,
}
