--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local addMechanicBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> ()
local callMechanicBinding: (key: unknown, ...unknown) -> ()
do
	local clientBindings = require(
		ReplicatedStorage:WaitForChild("WTHClientCore")
			:WaitForChild("controllers")
			:WaitForChild("MechanicController")
			:WaitForChild("bindings")
	)
	addMechanicBinding = clientBindings.addMechanicBinding
	callMechanicBinding = clientBindings.callMechanicBinding
end

--- Bindings to the Welcome To Hell controllers.
local bindings = {

	_addMechanicBinding = addMechanicBinding,
	_callMechanicBinding = callMechanicBinding,
}

--- Bindings to Welcome To Hell's background music.
bindings.BackgroundMusicController = {}
do
	function bindings.BackgroundMusicController.setTransitionTime(time: number)
		callMechanicBinding("@core/BackgroundMusicController/setTransitionTime", time)
	end

	table.freeze(bindings.BackgroundMusicController)
end

--- Bindings to Welcome To Hell's user interface.
bindings.UiController = {}
do
	--- Toggles if the run info timer is visible.
	--- @note The Kit does not implement the run timer. This is intended for
	--- cinematics that require more focus.
	function bindings.UiController.toggleRunTimerVisible()
		callMechanicBinding("@game/MenuController/toggleRunTimerVisible")
	end

	--- Sets if the run info timer is visible.
	--- @note The Kit does not implement the run timer. This is intended for
	--- cinematics that require more focus.
	function bindings.UiController.setRunTimerVisible(visible: boolean)
		callMechanicBinding("@game/MenuController/setRunTimerVisible", visible)
	end

	--- Sets the tower name below in the run timer. If `newName` is not provided,
	--- this resets the tower to the usual tower name.
	--- @note The Kit does not implement the run timer. This is intended for
	--- cinematics that require more focus.
	function bindings.UiController.setRunInfoTowerName(newName: string?)
		callMechanicBinding("@game/MenuController/setRunInfoTowerName", newName)
	end

	--- Sets if the tower name below in the run timer should be visible.
	--- @note The Kit does not implement the run timer. This is intended for
	--- cinematics that require more focus.
	function bindings.UiController.setRunInfoTowerNameVisible(visible: boolean)
		callMechanicBinding("@game/MenuController/setRunInfoTowerNameVisible", visible)
	end

	--- Toggles if the tower name below in the run timer should be visible.
	--- @note The Kit does not implement the run timer. This is intended for
	--- cinematics that require more focus.
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
