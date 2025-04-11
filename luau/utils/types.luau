--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Jecs = require(script.Parent.Jecs)

export type Typechecker = (value: unknown) -> (boolean, string?)
export type Cleanup = () -> ()

export type MechanicComponent<Attributes, Instance> = {
	attributes: Jecs.Entity<Attributes>,
	instance: Jecs.Entity<Attributes>,
}

export type Mechanic = {
	type: "Mechanic",
	name: string,
	attach: (wth: WthApi) -> (),
	persistant: boolean?,
}

export type WthApi = {
	world: Jecs.World,
	-- FIXME: Roblox is stinky doo doo so i have to downtype this
	createMechanicTag: (tag: string, instanceCheck: Typechecker?) -> any,
	createMechanicAttributes: (
		tag: any,
		attributeChecks: { [string]: Typechecker },
		defaultAttributes: { [string]: any }
	) -> any,
	pushSystems: (...() -> ()) -> (),

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

export type InstanceAttributeReconciler<T> = {
	type: "InstanceAttributeReconciler",
	check: Typechecker,
	attributeName: string,
	defaultValue: T,
	reconcile: (self: InstanceAttributeReconciler<T>, instance: Instance) -> T,
	destroy: (self: InstanceAttributeReconciler<T>) -> (),
}

-- Trove

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
