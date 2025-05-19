--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local addKitBinding: (key: unknown, fn: (...unknown) -> ...unknown) -> ()
local callKitBinding: (key: unknown, ...unknown) -> ()
do
	local clientBindings = require(
		ReplicatedStorage:WaitForChild("WTHClientCore")
			:WaitForChild("controllers")
			:WaitForChild("KitObjectController")
			:WaitForChild("bindings")
	)
	addKitBinding = clientBindings.addKitBinding
	callKitBinding = clientBindings.callKitBinding
end

--- @class KitStdBindings
--- Bindings to the Welcome To Hell controllers.
local bindings = {

	_addKitBinding = addKitBinding,
	_callKitBinding = callKitBinding,
}

--- @class BackgroundMusicController
--- Bindings to Welcome To Hell's background music.
bindings.BackgroundMusicController = {}
do
	function bindings.BackgroundMusicController.setTransitionTime(time: number)
		callKitBinding("@core/BackgroundMusicController/setTransitionTime", time)
	end

	table.freeze(bindings.BackgroundMusicController)
end

--- @class UiController
--- Bindings to Welcome To Hell's user interface.
bindings.UiController = {}
do
	function bindings.UiController.toggleRunTimerVisible()
		callKitBinding("@game/MenuController/toggleRunTimerVisible")
	end

	function bindings.UiController.setRunTimerVisible(visible: boolean)
		callKitBinding("@game/MenuController/setRunTimerVisible", visible)
	end

	function bindings.UiController.setRunInfoTowerName(newName: string?)
		callKitBinding("@game/MenuController/setRunInfoTowerName", newName)
	end

	function bindings.UiController.setRunInfoTowerNameVisible(visible: boolean)
		callKitBinding("@game/MenuController/setRunInfoTowerNameVisible", visible)
	end

	function bindings.UiController.toggleRunInfoTowerNameVisible()
		callKitBinding("@game/MenuController/toggleRunInfoTowerNameVisible")
	end

	function bindings.UiController.setMenuVisible(visible: boolean)
		callKitBinding("@game/MenuController/setMenuVisible", visible)
	end

	function bindings.UiController.toggleMenuVisible()
		callKitBinding("@game/MenuController/toggleMenuVisible")
	end

	table.freeze(bindings.UiController)
end

table.freeze(bindings)
return bindings
