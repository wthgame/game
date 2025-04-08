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

export type Mechanic<A, I, M> = M & {
	type: "Mechanic",
	name: string,
	-- TODO: once new luau solver is stable, swap to keyof<A>
	attributes: { [string]: Typechecker },
	defaultAttributes: A,
	instanceCheck: Typechecker,
	mechanize: (self: Mechanic<A, I, M>, ctx: MechanizeContext<A, I>) -> (),
}

export type MechanizeContext<A, I> = {
	id: number,
	instance: I,
	mechanicsFolder: Instance,
	getAttribute: (attribute: string) -> any,
	getAllAttributes: () -> A,
	trove: Trove,

	logTrace: (...unknown) -> (),
	logDebug: (...unknown) -> (),
	logInfo: (...unknown) -> (),
	logWarn: (...unknown) -> (),
	logError: (...unknown) -> (),
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

export type Trove = {
	extend: (self: Trove) -> Trove,
	clone: <T>(self: Trove, instance: T & Instance) -> T,
	construct: <T, A...>(self: Trove, class: Constructable<T, A...>, A...) -> T,
	connect: (self: Trove, signal: SignalLike | RBXScriptSignal, fn: (...any) -> ...any) -> ConnectionLike,
	bindToRenderStep: (self: Trove, name: string, priority: number, fn: (dt: number) -> ()) -> (),
	addPromise: <T>(self: Trove, promise: T & PromiseLike) -> T,
	add: <T>(self: Trove, object: T & TroveTrackable, cleanupMethod: string?) -> T,
	remove: <T>(self: Trove, object: T & TroveTrackable) -> boolean,
	clean: (self: Trove) -> (),
	wrapClean: (self: Trove) -> () -> (),
	attachToInstance: (self: Trove, instance: Instance) -> RBXScriptConnection,
	destroy: (self: Trove) -> (),
}

export type TroveTrackable =
	Instance
	| RBXScriptConnection
	| ConnectionLike
	| PromiseLike
	| thread
	| ((...any) -> ...any)
	| Destroyable
	| DestroyableLowercase
	| Disconnectable
	| DisconnectableLowercase

type ConnectionLike = {
	Connected: boolean,
	Disconnect: (self: ConnectionLike) -> (),
}

type SignalLike = {
	Connect: (self: SignalLike, callback: (...any) -> ...any) -> ConnectionLike,
	Once: (self: SignalLike, callback: (...any) -> ...any) -> ConnectionLike,
}

type PromiseLike = {
	getStatus: (self: PromiseLike) -> string,
	finally: (self: PromiseLike, callback: (...any) -> ...any) -> PromiseLike,
	cancel: (self: PromiseLike) -> (),
}

type Constructable<T, A...> = { new: (A...) -> T } | (A...) -> T

type Destroyable = {
	Destroy: (self: Destroyable) -> (),
}

type DestroyableLowercase = {
	destroy: (self: DestroyableLowercase) -> (),
}

type Disconnectable = {
	Disconnect: (self: Disconnectable) -> (),
}

type DisconnectableLowercase = {
	disconnect: (self: DisconnectableLowercase) -> (),
}

return nil
