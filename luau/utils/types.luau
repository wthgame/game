type Maybe<T> = T | nil
type Typechecker = (value: unknown) -> (boolean, string?)

export type Task =
	| Instance
	| RBXScriptConnection
	| thread
	| () -> ()
	| { [unknown]: unknown, destroy: (self: unknown) -> () }
	| { [unknown]: unknown, Destroy: (self: unknown) -> () }
	| { [unknown]: unknown, disconnect: (self: unknown) -> () }
	| { [unknown]: unknown, Disconnect: (self: unknown) -> () }

export type Scope<Methods> = { Task } & Methods

export type Mechanic<A, I> = {
	type: "Mechanic",
	name: string,
	-- TODO: once new luau solver is stable, swap to keyof<A>
	attributes: { [string]: Typechecker },
	defaultAttributes: A,
	instanceCheck: Typechecker,
	mechanize: (self: Mechanic<A, I>, ctx: MechanizeContext<A, I>) -> (),
}

export type MechanizeContext<A, I> = {
	id: number,
	instance: I,
	mechanicsFolder: Instance,
	getAttribute: (self: MechanizeContext<A, I>, attribute: string) -> any,
	pushTasks: <Tasks...>(self: MechanizeContext<A, I>, Tasks...) -> Tasks...,
}

export type TouchConfig = {
	passLocalPlayerCharacters: boolean?,
	passAllPlayerCharacters: boolean?,
}

export type Character = Model & {
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator,
	},
	HumanoidRootPart: BasePart,
	BodyColors: BodyColors,
	PrimaryPart: BasePart,
	Animate: LocalScript,
	Head: BasePart,
}

return nil
