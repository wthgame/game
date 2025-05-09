import { t } from "@rbxts/t";

export const BackgroundMusicZoneInstance = t.children({
	Part: t.instanceIsA("BasePart"),
	Sound: t.instanceIsA("Sound"),
});

export interface BackgroundMusicZoneInstance extends t.static<typeof BackgroundMusicZoneInstance> {}

export interface TowerInstance extends Instance {
	Mechanics: Instance;
	Obby: Instance;
	Decoration: Instance;
	Frame: Instance;
	Spawn: BasePart;
	BackgroundMusicZones: Instance;
}
