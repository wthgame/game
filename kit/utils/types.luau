--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local t = require("./packages/t")
local trove = require("./packages/trove")

export type Map<K, V> = { [K]: V }
export type Set<T> = { [T]: true }

export type InstanceTag<I> = {
	instances: (self: InstanceTag<I>) -> { I },
	onActivated: (
		self: InstanceTag<I>,
		callback: (trove: trove.Trove, instance: I, activationTrove: trove.Trove) -> ()
	) -> (),
	onLoaded: (self: InstanceTag<I>, callback: (trove: trove.Trove, instance: I) -> ()) -> (),
}

export type Kit = {
	trove: trove.Trove,
	tag: ((self: Kit, tagName: string) -> InstanceTag<Instance>)
		& (<I>(self: Kit, tagName: string, check: t.check<I>?) -> InstanceTag<I>),
	onRender: (self: Kit, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	onPhysics: (self: Kit, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	onTick: (self: Kit, callback: (trove: trove.Trove, dt: number) -> ()) -> (),
	mechanics: Instance,
}

export type KitScript<Self> = Self & {
	type: "KitScript",
	run: (self: KitScript<Self>, kit: Kit) -> (),
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

export type InstanceByIds<T = Instance, I = string> = {
	getAll: (self: InstanceByIds<T, I>) -> Map<I, Set<T>>,
	getId: (self: InstanceByIds<T, I>, id: I) -> Set<T>,
	add: (self: InstanceByIds<T, I>, instance: T, id: I) -> T,
	remove: (self: InstanceByIds<T, I>, instance: T, id: I) -> T,
	destroy: (self: InstanceByIds<T, I>) -> (),
}

export type PlaySoundConfig = {
	speed: number?,
	volume: number?,
}

export type TweenConfig = {
	time: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	repeatCount: number?,
	reverse: boolean?,
	delayTime: number?,
}

return nil
