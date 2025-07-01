--- @class Bin
--- Collects object during runtime that needs to be destroyed later.
export type Bin = {
	type: "Bin",
	destroyed: boolean,
	destroyCallback: () -> (),

	add: <T>(self: Bin, binnable: T & Binnable) -> T,
	addTuple: <T...>(self: Bin, T...) -> T...,
	remove: <T>(self: Bin, binnable: T & Binnable) -> T,
	removeTuple: <T...>(self: Bin, T...) -> T...,
	extend: (self: Bin) -> Bin,
	attachToInstance: <T>(self: Bin, instance: T & Instance) -> (T, RBXScriptConnection),
	destroy: (self: Bin) -> (),
}

-- stylua: ignore
export type Binnable =
    | Instance
    | RBXScriptConnection
    | (() -> ...unknown)
    | thread
    | BinnableMethods
    | Bin
    | { Binnable }

export type BinnableMethods = {
	disconnect: ((self: unknown) -> ())?,
	Disconnect: ((self: unknown) -> ())?,
	destroy: ((self: unknown) -> ())?,
	Destroy: ((self: unknown) -> ())?,
}

local BINNABLE_METHODS = {
	disconnect = true,
	Disconnect = true,
	destroy = true,
	Destroy = true,
}

local function destroy(binnable: Binnable)
	if typeof(binnable) == "Instance" then
		binnable:Destroy()
	elseif typeof(binnable) == "RBXScriptConnection" and binnable.Connected then
		binnable:Disconnect()
	elseif typeof(binnable) == "function" then
		binnable()
	elseif typeof(binnable) == "thread" then
		pcall(task.cancel, binnable)
	elseif typeof(binnable) == "table" then
		if (binnable :: Bin).type == "Bin" then
			(binnable :: Bin):destroy()
			return
		end

		for method in BINNABLE_METHODS do
			if typeof(binnable[method]) == "function" then
				binnable[method](binnable)
			end
		end

		if binnable[1] then
			for index = #binnable, 1, -1 do
				destroy(binnable[index])
			end
		end
	end
end

local function createBin(): Bin
	local binnables = {}
	local self = {
		type = "Bin",
		destroyed = false,
	} :: Bin

	function self:add<T>(binnable)
		table.insert(binnables, binnable)
		return binnable
	end

	function self:addTuple<T...>(...)
		for index = 1, select("#", ...) do
			table.insert(binnables, select(index, ...))
		end
		return ...
	end

	function self:remove<T>(binnable)
		table.remove(binnables, table.find(binnables, binnable :: any))
		return binnable
	end

	function self:removeTuple<T...>(...)
		for index = 1, select("#", ...) do
			table.remove(binnables, table.find(binnables, select(index, ...)))
		end
		return ...
	end

	function self:extend()
		return self:add(createBin())
	end

	function self:attachToInstance<T>(instance)
		return instance, self:add(instance.Destroying:Connect(self.destroyCallback))
	end

	function self:destroy()
		if not self.destroyed then
			self.destroyed = true
			for index = #binnables, 1, -1 do
				destroy(binnables[index] :: any)
			end
		end
	end

	return self
end

return {
	createBin = createBin,
	destroy = destroy,
}
