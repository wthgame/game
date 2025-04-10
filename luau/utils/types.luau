local jecs = require(script.Parent.jecs)

export type Typechecker = (value: unknown) -> (boolean, string?)

export type MechanicComponent<Attributes, Instance> = jecs.Entity<{
	attributes: Attributes,
	instance: Instance,
}>

export type Mechanic = {
	type: "Mechanic",
	name: string,
	attach: (wth: WelcomeToHell) -> (),
}

export type WelcomeToHell = {
	world: jecs.World,
	createMechanic: <Attributes, Instance>(
		tag: string,
		attributeChecks: { [string]: Typechecker },
		defaultAttributes: Attributes,
		instanceCheck: Typechecker
	) -> jecs.Entity<MechanicComponent<Attributes, Instance>>,
	pushSystems: (...() -> ()) -> (),
}

return nil
