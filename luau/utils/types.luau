local jecs = require(script.Parent.jecs)

export type Typechecker = (value: unknown) -> (boolean, string?)

export type MechanicComponent<Attributes, Instance> = {
	attributes: jecs.Entity<Attributes>,
	instance: jecs.Entity<Attributes>,
}

export type Mechanic = {
	type: "Mechanic",
	name: string,
	attach: (wth: WelcomeToHell) -> (),
}

export type WelcomeToHell = {
	world: jecs.World,
	-- FIXME: Roblox is stinky doo doo so i have to downtype this
	createMechanicTag: (tag: string, instanceCheck: Typechecker?) -> any,
	createMechanicAttributes: (
		tag: any,
		attributeChecks: { [string]: Typechecker },
		defaultAttributes: { [string]: any }
	) -> any,
	pushSystems: (...() -> ()) -> (),
}

return nil
