type Maybe<T> = T | nil

export type Mechanic<Config> = {
	type: "Mechanic",
	name: string,
	configCheck: Maybe<{ [string]: (unknown) -> (boolean, string?) }>,
	instanceCheck: Maybe<(parent: Instance) -> (boolean, string?)>,
	attach: (self: Mechanic<Config>, mech: MechanicToAttach<Config>) -> (),
}

export type MechanicToAttach<Config> = {
	parent: Instance,
	config: Config,
}

return nil
