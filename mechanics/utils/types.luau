--!strict

local t = require("./packages/t")
local trove = require("./packages/trove")

export type Map<K, V> = { [K]: V }

export type KitContext = {
	isDebug: (self: KitContext) -> boolean,
}

export type MechanicContext<I, A> = {
	attribute: (self: MechanicContext<I, A>, instance: I, key: string) -> any,
}

export type Mechanic<I, A> = {
	type: "Mechanic",
	minimumKitVersion: string?,
	instanceTag: string,
	instanceCheck: t.check<any>?,
	defaultAttributes: Map<string, any>,
	attributeChecks: Map<string, t.check<any>>,
	persistent: boolean?,

	loaded: (mechanic: MechanicContext<I, A>, trove: trove.Trove, instance: I, kit: KitContext) -> (),
	unloaded: (mechanic: MechanicContext<I, A>, trove: trove.Trove, instance: I, kit: KitContext) -> (),
	kitLoaded: (mechanic: MechanicContext<I, A>, trove: trove.Trove, kit: KitContext) -> (),
	kitUnloaded: (mechanic: MechanicContext<I, A>, trove: trove.Trove, kit: KitContext) -> (),
}

export type WTH = {
	registerMechanic: (...Mechanic<any, any>) -> (),
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
