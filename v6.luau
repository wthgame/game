--!strict
--\\ Typewriter
--// By Synnwave (somewhere in july 2022)
--\\ please do not edit this module !!!!!!!!!!
--// please do not edit/add texts effects !!!!!!!!!!
--\\ you may use this script for your own game, but please credit me (Synnwave) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

local shared = require(script.Shared)
local Typewriter = {
	_currentNum = 0,
	_frame = nil,
	_frameConnections = {},
}

function Typewriter:ChangeFrame(frame: Frame, ignoreChildEvents: boolean?)
	if not frame then
		return
	end
	self._frame = frame
	self._currentNum = 0

	for i, connection: RBXScriptConnection in self._frameConnections do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
			self._frameConnections[i] = nil
		end
	end

	if not ignoreChildEvents then
		table.insert(
			self._frameConnections,
			frame.ChildAdded:Connect(function(child: Instance)
				self:_check(child)
			end)
		)

		table.insert(
			self._frameConnections,
			frame.ChildRemoved:Connect(function()
				self:_refresh()
			end)
		)
	end
end

local function utf8sub(s: string, i: number, j: number): string
	return string.sub(s, utf8.offset(s, i), utf8.offset(s, j + 1) - 1)
end

local modes = {
	default = require(script.TypeModes.Main),
	alternative = require(script.TypeModes.WrapWords),
}

function Typewriter:Write(textInfo)
	local textSorter: Frame = Instance.new("Frame")
	textSorter.BackgroundTransparency = 1
	textSorter.Size = UDim2.new(1, 0, self._frame.Size.Y)
	textSorter.ZIndex = 151
	textSorter.Parent = self._frame :: any

	local listLayout: UIListLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 0)
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = textSorter

	if textInfo.UseAlternative then
		return modes.alternative(textInfo, textSorter, self._frame)
	else
		return modes.default(textInfo, textSorter, self._frame)
	end
end

function Typewriter:_check(child: Instance)
	if child:IsA("GuiObject") then
		Typewriter._currentNum += 1
		child.Name = self._currentNum
		self:_refresh()
	end
end

function Typewriter:_refresh()
	local totalDialogs = {}
	for i, dialogFrame in self._frame:GetChildren() do
		table.insert(totalDialogs, dialogFrame)
	end

	local found: { TextLabel } = {}
	local function recursiveSearch()
		local current: TextLabel
		for i, frameFound: TextLabel in totalDialogs do
			local currentNumber: number? = (current and tonumber(current.Name))
			local nextFrameNumber: number? = tonumber(frameFound.Name)
			if (not current) or ((nextFrameNumber and currentNumber) and (currentNumber < nextFrameNumber)) then
				current = frameFound
			end
		end

		if current then
			local foundInTable: number? = table.find(totalDialogs, current)
			if foundInTable then
				table.remove(totalDialogs, foundInTable)
			end

			table.insert(found, current)
		end

		if #totalDialogs > 0 then
			recursiveSearch()
		end
	end

	recursiveSearch()

	for i: number, currentFrame: TextLabel in found do
		shared.Spr.target(currentFrame, 0.55, 2.35, { Position = UDim2.fromOffset(0, -40 * (i - 1)) })
	end
end

return Typewriter
