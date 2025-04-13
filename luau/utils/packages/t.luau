--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

type Literal = string | number | boolean | nil | {}
export type Check<T> = ((value: unknown) -> (boolean, string?)) & { _T: (never) -> T }

-- i love handwritting types
export type t = {
	type: (typeName: string) -> Check<any>,
	typeof: (typeName: string) -> Check<any>,
	any: Check<any>,
	boolean: Check<boolean>,
	buffer: Check<buffer>,
	thread: Check<thread>,
	callback: Check<(...unknown) -> unknown>,
	["function"]: Check<(...unknown) -> unknown>,
	none: Check<nil>,
	["nil"]: Check<nil>,
	number: Check<number>,
	nan: Check<number>,
	string: Check<string>,
	table: Check<{ [unknown]: unknown }>,
	userdata: Check<unknown>,
	vector: Check<vector>,

	Axes: Check<Axes>,
	BrickColor: Check<BrickColor>,
	CatalogSearchParams: Check<CatalogSearchParams>,
	CFrame: Check<CFrame>,
	Content: Check<Content>,
	Color3: Check<Color3>,
	ColorSequence: Check<ColorSequence>,
	ColorSequenceKeypoint: Check<ColorSequenceKeypoint>,
	DateTime: Check<DateTime>,
	DockWidgetPluginGuiInfo: Check<DockWidgetPluginGuiInfo>,
	Enum: Check<Enum>,
	EnumItem: Check<EnumItem>,
	Enums: Check<Enums>,
	Faces: Check<Faces>,
	FloatCurveKey: Check<FloatCurveKey>,
	Font: Check<Font>,
	Instance: Check<Instance>,
	NumberRange: Check<NumberRange>,
	NumberSequence: Check<NumberSequence>,
	NumberSequenceKeypoint: Check<NumberSequenceKeypoint>,
	OverlapParams: Check<OverlapParams>,
	PathWaypoint: Check<PathWaypoint>,
	PhysicalProperties: Check<PhysicalProperties>,
	Random: Check<Random>,
	Ray: Check<Ray>,
	RaycastParams: Check<RaycastParams>,
	RaycastResult: Check<RaycastResult>,
	RBXScriptConnection: Check<RBXScriptConnection>,
	RBXScriptSignal: Check<RBXScriptSignal>,
	Rect: Check<Rect>,
	Region3: Check<Region3>,
	Region3int16: Check<Region3int16>,
	TweenInfo: Check<TweenInfo>,
	UDim: Check<UDim>,
	UDim2: Check<UDim2>,
	Vector2: Check<Vector2>,
	Vector2int16: Check<Vector2int16>,
	Vector3: Check<Vector3>,
	Vector3int16: Check<Vector3int16>,

	enum: (enum: Enum) -> Check<EnumItem>,

	literalList: (checks: { Check<Literal> }) -> Check<any>,
	literal: (<A, B>(A, B) -> Check<A | B>)
		& (<A, B, C>(A, B, C) -> Check<A | B | C>)
		& (<A, B, C, D>(A, B, C, D) -> Check<A | B | C | D>)
		& (<A, B, C, D, E>(A, B, C, D, E) -> Check<A | B | C | D | E>)
		& ((...any) -> Check<any>),
	keyOf: <K>(valueTable: { [K]: unknown }) -> Check<K>,
	valueOf: <V>(valueTable: { [unknown]: V }) -> Check<V>,
	integer: Check<number>,
	numberMin: (min: number) -> Check<number>,
	numberMax: (max: number) -> Check<number>,
	numberMinExclusive: (min: number) -> Check<number>,
	numberMaxExclusive: (max: number) -> Check<number>,
	numberPositive: Check<number>,
	numberNegative: Check<number>,
	numberConstrained: (min: number, max: number) -> Check<number>,
	numberConstrainedExclusive: (min: number, max: number) -> Check<number>,
	match: (pattern: string) -> Check<string>,
	optional: <T>(check: Check<T>) -> Check<T | nil>,
	keys: <T>(check: Check<T>) -> Check<{ [T]: unknown }>,
	values: <T>(check: Check<T>) -> Check<{ [unknown]: T }>,
	map: <K, V>(keyCheck: Check<K>, valueCheck: Check<V>) -> Check<{ [K]: V }>,
	set: <T>(valueCheck: Check<T>) -> Check<{ [T]: true }>,
	array: <T>(check: Check<T>) -> Check<{ T }>,
	strictArray: (...Check<any>) -> Check<{ any }>,
	unionList: (checks: { Check<any> }) -> Check<any>,
	union: (<A, B>(Check<A>, Check<B>) -> Check<A | B>)
		& (<A, B, C>(Check<A>, Check<B>, Check<C>) -> Check<A | B | C>)
		& (<A, B, C, D>(Check<A>, Check<B>, Check<C>, Check<D>) -> Check<A | B | C | D>)
		& (<A, B, C, D, E>(Check<A>, Check<B>, Check<C>, Check<D>, Check<E>) -> Check<A | B | C | D | E>)
		& ((...Check<any>) -> Check<any>),
	intersectionList: (checks: { Check<any> }) -> Check<any>,
	intersection: (<A, B>(Check<A>, Check<B>) -> Check<A & B>)
		& (<A, B, C>(Check<A>, Check<B>, Check<C>) -> Check<A & B & C>)
		& (<A, B, C, D>(Check<A>, Check<B>, Check<C>, Check<D>) -> Check<A & B & C & D>)
		& (<A, B, C, D, E>(Check<A>, Check<B>, Check<C>, Check<D>, Check<E>) -> Check<A & B & C & D & E>)
		& ((...Check<any>) -> Check<any>),
	interface: (checkTable: { [string]: Check<any> }) -> Check<any>,
	strictInterface: (checkTable: { [string]: Check<any> }) -> Check<any>,
	instanceOf: (className: string, checkTable: { [string]: Check<any> }?) -> Check<Instance>,
	instanceIsA: (className: string, checkTable: { [string]: Check<any> }?) -> Check<Instance>,
	children: (checkTable: { [string]: Check<any> }?) -> Check<Instance>,
}

local t: t = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("WTHShared")
		:WaitForChild("include")
		:WaitForChild("node_modules")
		:WaitForChild("@rbxts")
		:WaitForChild("t")
		:WaitForChild("lib")
		:WaitForChild("ts")
).t :: any

return t
