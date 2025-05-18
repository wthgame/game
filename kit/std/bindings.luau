--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local addMechanicBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> ()
local callMechanicBinding: (key: unknown, ...unknown) -> ()
do
	local clientBindings = require(
		ReplicatedStorage:WaitForChild("WTHClientCore")
			:WaitForChild("controllers")
			:WaitForChild("KitObjectController")
			:WaitForChild("bindings")
	)
	addMechanicBinding = clientBindings.addMechanicBinding
	callMechanicBinding = clientBindings.callMechanicBinding
end

--- @class KitStdBindings
--- Bindings to the Welcome To Hell controllers.
local bindings = {

	_addMechanicBinding = addMechanicBinding,
	_callMechanicBinding = callMechanicBinding,
}

--- @class BackgroundMusicController
--- Bindings to Welcome To Hell's background music.
bindings.BackgroundMusicController = {}
do
	function bindings.BackgroundMusicController.setTransitionTime(time: number)
		callMechanicBinding("@core/BackgroundMusicController/setTransitionTime", time)
	end

	table.freeze(bindings.BackgroundMusicController)
end

--- @class UiController
--- Bindings to Welcome To Hell's user interface.
bindings.UiController = {}
do
	function bindings.UiController.toggleRunTimerVisible()
		callMechanicBinding("@game/MenuController/toggleRunTimerVisible")
	end

	function bindings.UiController.setRunTimerVisible(visible: boolean)
		callMechanicBinding("@game/MenuController/setRunTimerVisible", visible)
	end

	function bindings.UiController.setRunInfoTowerName(newName: string?)
		callMechanicBinding("@game/MenuController/setRunInfoTowerName", newName)
	end

	function bindings.UiController.setRunInfoTowerNameVisible(visible: boolean)
		callMechanicBinding("@game/MenuController/setRunInfoTowerNameVisible", visible)
	end

	function bindings.UiController.toggleRunInfoTowerNameVisible()
		callMechanicBinding("@game/MenuController/toggleRunInfoTowerNameVisible")
	end

	function bindings.UiController.setMenuVisible(visible: boolean)
		callMechanicBinding("@game/MenuController/setMenuVisible", visible)
	end

	function bindings.UiController.toggleMenuVisible()
		callMechanicBinding("@game/MenuController/toggleMenuVisible")
	end

	table.freeze(bindings.UiController)
end

table.freeze(bindings)
return bindings
