type Cleanup = () -> ()

export type Mechanic = {
	-- tower: Instance,
	-- mechanics: Instance,
	-- obby: Instance,
	-- design: Instance,
	-- frame: Instance,

	instance: Instance,
}

export type MechanicProps = {
	-- ???
	-- init: () -> Cleanup?,
	init: ((self: Mechanic) -> ()) | ((self: Mechanic) -> Cleanup?),
}

local lib = {}

function lib.mechanic(props: MechanicProps)
	return table.freeze(props)
end

table.freeze(lib)
return lib
