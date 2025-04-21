--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

type Literal = string | number | boolean | nil | {}
export type check<T> = ((value: unknown) -> (boolean, string?)) & { _T: (never) -> T }

-- i love handwritting types
export type t = {
	type: (typeName: string) -> check<any>,
	typeof: (typeName: string) -> check<any>,
	any: check<any>,
	boolean: check<boolean>,
	buffer: check<buffer>,
	thread: check<thread>,
	callback: check<(...unknown) -> unknown>,
	["function"]: check<(...unknown) -> unknown>,
	none: check<nil>,
	["nil"]: check<nil>,
	number: check<number>,
	nan: check<number>,
	string: check<string>,
	table: check<{ [unknown]: unknown }>,
	userdata: check<unknown>,
	vector: check<vector>,

	Axes: check<Axes>,
	BrickColor: check<BrickColor>,
	CatalogSearchParams: check<CatalogSearchParams>,
	CFrame: check<CFrame>,
	Content: check<Content>,
	Color3: check<Color3>,
	ColorSequence: check<ColorSequence>,
	ColorSequenceKeypoint: check<ColorSequenceKeypoint>,
	DateTime: check<DateTime>,
	DockWidgetPluginGuiInfo: check<DockWidgetPluginGuiInfo>,
	Enum: check<Enum>,
	EnumItem: check<EnumItem>,
	Enums: check<Enums>,
	Faces: check<Faces>,
	FloatCurveKey: check<FloatCurveKey>,
	Font: check<Font>,
	Instance: check<Instance>,
	NumberRange: check<NumberRange>,
	NumberSequence: check<NumberSequence>,
	NumberSequenceKeypoint: check<NumberSequenceKeypoint>,
	OverlapParams: check<OverlapParams>,
	PathWaypoint: check<PathWaypoint>,
	PhysicalProperties: check<PhysicalProperties>,
	Random: check<Random>,
	Ray: check<Ray>,
	RaycastParams: check<RaycastParams>,
	RaycastResult: check<RaycastResult>,
	RBXScriptConnection: check<RBXScriptConnection>,
	RBXScriptSignal: check<RBXScriptSignal>,
	Rect: check<Rect>,
	Region3: check<Region3>,
	Region3int16: check<Region3int16>,
	TweenInfo: check<TweenInfo>,
	UDim: check<UDim>,
	UDim2: check<UDim2>,
	Vector2: check<Vector2>,
	Vector2int16: check<Vector2int16>,
	Vector3: check<Vector3>,
	Vector3int16: check<Vector3int16>,

	enum: (enum: Enum) -> check<EnumItem>,

	literalList: (checks: { check<Literal> }) -> check<any>,
	literal: (<A, B>(check<A>, check<B>) -> check<A | B>)
		& (<A, B, C>(check<A>, check<B>, check<C>) -> check<A | B | C>)
		& (<A, B, C, D>(check<A>, check<B>, check<C>, check<D>) -> check<A | B | C | D>)
		& (<A, B, C, D, E>(check<A>, check<B>, check<C>, check<D>, check<E>) -> check<A | B | C | D | E>)
		& ((...any) -> check<any>),
	keyOf: <K>(valueTable: { [K]: unknown }) -> check<K>,
	valueOf: <V>(valueTable: { [unknown]: V }) -> check<V>,
	integer: check<number>,
	numberMin: (min: number) -> check<number>,
	numberMax: (max: number) -> check<number>,
	numberMinExclusive: (min: number) -> check<number>,
	numberMaxExclusive: (max: number) -> check<number>,
	numberPositive: check<number>,
	numberNegative: check<number>,
	numberConstrained: (min: number, max: number) -> check<number>,
	numberConstrainedExclusive: (min: number, max: number) -> check<number>,
	match: (pattern: string) -> check<string>,
	optional: <T>(check: check<T>) -> check<T | nil>,
	keys: <T>(check: check<T>) -> check<{ [T]: unknown }>,
	values: <T>(check: check<T>) -> check<{ [unknown]: T }>,
	map: <K, V>(keycheck: check<K>, valuecheck: check<V>) -> check<{ [K]: V }>,
	set: <T>(valuecheck: check<T>) -> check<{ [T]: true }>,
	array: <T>(check: check<T>) -> check<{ T }>,
	strictArray: (...check<any>) -> check<{ any }>,
	unionList: (checks: { check<any> }) -> check<any>,
	union: (<A, B>(check<A>, check<B>) -> check<A | B>)
		& (<A, B, C>(check<A>, check<B>, check<C>) -> check<A | B | C>)
		& (<A, B, C, D>(check<A>, check<B>, check<C>, check<D>) -> check<A | B | C | D>)
		& (<A, B, C, D, E>(check<A>, check<B>, check<C>, check<D>, check<E>) -> check<A | B | C | D | E>)
		& ((...check<any>) -> check<any>),
	intersectionList: (checks: { check<any> }) -> check<any>,
	intersection: (<A, B>(check<A>, check<B>) -> check<A & B>)
		& (<A, B, C>(check<A>, check<B>, check<C>) -> check<A & B & C>)
		& (<A, B, C, D>(check<A>, check<B>, check<C>, check<D>) -> check<A & B & C & D>)
		& (<A, B, C, D, E>(check<A>, check<B>, check<C>, check<D>, check<E>) -> check<A & B & C & D & E>)
		& ((...check<any>) -> check<any>),
	interface: (checkTable: { [string]: check<any> }) -> check<any>,
	strictInterface: (checkTable: { [string]: check<any> }) -> check<any>,
	instanceOf: (className: string, checkTable: { [string]: check<any> }?) -> check<Instance>,
	instanceIsA: (className: string, checkTable: { [string]: check<any> }?) -> check<Instance>,
	children: (checkTable: { [string]: check<any> }?) -> check<Instance>,
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
