--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

type Bindings = {
	addMechanicBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> (),
	callMechanicBinding: (key: unknown, ...unknown) -> (),
}

local bindings = require(
	ReplicatedStorage:WaitForChild("WTHClientCore")
		:WaitForChild("controllers")
		:WaitForChild("MechanicController")
		:WaitForChild("bindings")
) :: Bindings

return {
	addMechanicBinding = bindings.addMechanicBinding,
	callMechanicBinding = bindings.callMechanicBinding,
}
