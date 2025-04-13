local jecs = require("./packages/jecs")
local t = require("./packages/t")
local trove = require("./packages/trove")

type Trove = trove.Trove

export type Typechecker<T> = t.Check<T>

export type Mechanic<Self> = Self & {
	type: "Mechanic",
	name: string,
	persistent: boolean?,
	init: (self: Mechanic<Self>, wth: WTH) -> (),
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

export type WTH = {
	world: jecs.World,
	useTag: (self: WTH, tag: string, check: Typechecker<any>) -> any,
	useAttribute: <T>(
		self: WTH,
		attributeName: string,
		tag: jecs.Entity,
		check: Typechecker<T>,
		default: T
	) -> jecs.Entity<T>,
	schedule: (self: WTH, ...((dt: number, trove: Trove) -> ())) -> (),
}

return nil
