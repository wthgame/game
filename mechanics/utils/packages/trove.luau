--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

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
	-- wrapClean: (self: Trove) -> () -> (),
	attachToInstance: (self: Trove, instance: Instance) -> RBXScriptConnection,
	destroy: (self: Trove) -> (),
}

export type TroveLib = {
	Trove: Trove,
}

local trove: TroveLib = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("WTHShared")
		:WaitForChild("include")
		:WaitForChild("node_modules")
		:WaitForChild("@rbxts")
		:WaitForChild("trove")
		:WaitForChild("out")
) :: any

return trove
