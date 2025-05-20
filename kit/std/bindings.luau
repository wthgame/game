--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local addBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> ()
local callBinding: (key: unknown, ...unknown) -> ()
do
	local clientBindings = require(
		ReplicatedStorage:WaitForChild("WTHClientCore")
			:WaitForChild("controllers")
			:WaitForChild("KitObjectController")
			:WaitForChild("bindings")
	)
	addBinding = clientBindings.addBinding
	callBinding = clientBindings.callBinding
end

--- @class KitStdBindings
--- Bindings to the Welcome To Hell controllers.
local bindings = {

	_addBinding = addBinding,
	_callBinding = callBinding,
}

--- @class BackgroundMusicController
--- Bindings to Welcome To Hell's background music.
bindings.BackgroundMusicController = {}
do
	function bindings.BackgroundMusicController.setTransitionTime(time: number)
		callBinding("@core/BackgroundMusicController/setTransitionTime", time)
	end

	table.freeze(bindings.BackgroundMusicController)
end

--- @class UiController
--- Bindings to Welcome To Hell's user interface.
bindings.UiController = {}
do
	function bindings.UiController.toggleRunTimerVisible()
		callBinding("@game/MenuController/toggleRunTimerVisible")
	end

	function bindings.UiController.setRunTimerVisible(visible: boolean)
		callBinding("@game/MenuController/setRunTimerVisible", visible)
	end

	function bindings.UiController.setRunInfoTowerName(newName: string?)
		callBinding("@game/MenuController/setRunInfoTowerName", newName)
	end

	function bindings.UiController.setRunInfoTowerNameVisible(visible: boolean)
		callBinding("@game/MenuController/setRunInfoTowerNameVisible", visible)
	end

	function bindings.UiController.toggleRunInfoTowerNameVisible()
		callBinding("@game/MenuController/toggleRunInfoTowerNameVisible")
	end

	function bindings.UiController.setMenuVisible(visible: boolean)
		callBinding("@game/MenuController/setMenuVisible", visible)
	end

	function bindings.UiController.toggleMenuVisible()
		callBinding("@game/MenuController/toggleMenuVisible")
	end

	table.freeze(bindings.UiController)
end

table.freeze(bindings)
return bindings
