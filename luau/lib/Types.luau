local t = require("./packages/t")

export type Typechecker<T> = t.Check<T>

export type Mechanic<Self> = Self & {
	type: "Mechanic",
	name: string,
	persistant: boolean?,
	init: (self: Mechanic<Self>, schedule: ((dt: number) -> ()) -> ()) -> (),
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
