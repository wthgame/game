import Maybe from "@rbxts/libopen-maybe";
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

// TODO: remove link if not in studio
const NO_ETOH =
	"EToH kits with client objects aren't supported in Welcome To Hell, see section 1.1 'WTH for EToH' in The Tower Building Book:" +
	"\nhttps://welcome-to-hell.com/go/ttbb-1.1";

export function castToTowerInstance(instance: Instance): Maybe.Maybe<TowerInstance> {
	const mechanics = instance.FindFirstChild("Mechanics");
	const decoration = instance.FindFirstChild("Decoration");
	const obby = instance.FindFirstChild("Obby");
	const spawn = instance.FindFirstChild("Spawn");

	if (!mechanics) {
		const clientSidedObjects = instance.FindFirstChild("ClientSidedObjects");
		if (clientSidedObjects) return Maybe.None(NO_ETOH);
		return Maybe.None("No Mechanics folder found");
	}

	if (!decoration) return Maybe.None("No Decoration folder found");
	if (!obby) return Maybe.None("No Obby folder found");
	if (!spawn) return Maybe.None("No Spawn found");
	if (!spawn.IsA("BasePart")) return Maybe.None(`Expected Spawn to be a BasePart, got ${spawn.ClassName}`);

	return Maybe.Some(instance as TowerInstance);
}
