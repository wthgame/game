-- placeholder
type Trove = unknown
type check<T> = unknown

export type Kit = {
	tagObjectsParent: Instance,
	spawn: BasePart,
	kitType: "tower" | "area",
}

export type Tagged = {
	implements: { Tagged: true },
	tag: string,
	tagCheck: check<any>?,
	tagged: (self: Tagged, trove: Trove, instance: any) -> (),
}

export type OnKitLoad = {
	implements: { KitLoaded: true },
	onKitLoad: (self: OnKitLoad, kit: Kit) -> (),
}

export type MountsUi = {
	implements: { MountsUi: true },
	mountUi: (self: MountsUi) -> ScreenGui,
}

export type OnTick = {
	implements: { OnTick: true },
	onTick: (self: OnTick, dt: number) -> (),
}

local Conveyor = {} :: Tagged & OnTick
Conveyor.implements = {
	Tagged = true :: true,
	OnTick = true :: true,
}

Conveyor.tag = "Conveyor"

function Conveyor:tagged(trove, con: BasePart) end

function Conveyor:onTick(dt) end
