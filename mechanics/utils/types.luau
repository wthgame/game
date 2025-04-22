--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("./packages/t")
local trove = require("./packages/trove")

export type Map<K, V> = { [K]: V }
export type Set<T> = { [T]: true }

export type InstanceTag<I> = {
	instances: (self: InstanceTag<I>) -> { I },
	onLoaded: (self: InstanceTag<I>, callback: (trove: trove.Trove, instance: I) -> ()) -> (),
	onUnloaded: (self: InstanceTag<I>, callback: (trove: trove.Trove, instance: I) -> ()) -> (),
}

export type WTH = {
	tag: ((self: WTH, tagName: string) -> InstanceTag<Instance>)
		& (<I>(self: WTH, tagName: string, check: t.check<I>?) -> InstanceTag<I>),
	onRender: (self: WTH, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	onPhysics: (self: WTH, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	onTick: (self: WTH, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	onMechanicsLoaded: (self: WTH, callback: (trove: trove.Trove) -> ()) -> (),
	onMechanicsUnloaded: (self: WTH, callback: (trove: trove.Trove) -> ()) -> (),
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

export type PlaySoundConfig = {
	speed: number?,
	volume: number?,
}

return nil
