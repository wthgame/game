import { Controller, OnStart } from "@flamework/core";
import { atom, computed, effect } from "@rbxts/charm";
import ty from "@rbxts/libopen-ty";
import { Option } from "@rbxts/rust-classes";
import { CollectionService, MarketplaceService } from "@rbxts/services";
import { trace } from "core/shared/log";
import { BackgroundMusicZoneInstance } from "core/shared/types";
import { OnPreRender } from "../hook-managers/RenderHookManager";
import { CharacterController } from "./CharacterController";
import { addMechanicBinding } from "./MechanicController/bindings";

export const LOADED_ZONE_TAG = "LoadedBackgroundMusicZone";

function isPointInBounds(point: CFrame, boundsCFrame: CFrame, boundsSize: Vector3): boolean {
	const relativeCFrame = boundsCFrame.ToObjectSpace(point);
	return (
		math.abs(relativeCFrame.X) - boundsSize.X / 2 <= 0 &&
		math.abs(relativeCFrame.Y) - boundsSize.Y / 2 <= 0 &&
		math.abs(relativeCFrame.Z) - boundsSize.Z / 2 <= 0
	);
}

function getProductInfo(id: number) {
	return MarketplaceService.GetProductInfo(id);
}

@Controller()
export class BackgroundMusicController implements OnStart, OnPreRender {
	readonly nowPlaying = atom<Sound>();
	private lastPlaying = atom<Sound>();
	readonly defaultSound = atom<Sound>();

	private knownAssetInfo = atom(new Map<number, AssetProductInfo>());

	private async cacheAssetInfo(id: number) {
		const [infoSuccess, info] = pcall(getProductInfo, id);
		if (infoSuccess)
			this.knownAssetInfo((old) => {
				old = table.clone(old);
				old.set(id, info as AssetProductInfo);
				return old;
			});
	}

	readonly idOfNowPlaying = computed<Option<number>>(() => {
		const nowPlaying = this.nowPlaying();
		if (nowPlaying) {
			// some audio may not be number ids, ie. audios synced with
			// maau or asphalt
			const id = tonumber(nowPlaying.SoundId.gsub("rbxassetid://", "")[0]);
			if (id !== undefined) return Option.some(id);
		}
		return Option.none();
	});

	readonly assetInfoOfNowPlaying = computed<Option<AssetProductInfo>>(() => {
		return this.idOfNowPlaying().andWith((id) => {
			const cached = this.knownAssetInfo().get(id);
			if (cached) return Option.some(cached);
			// defer promise to get product info for later
			this.cacheAssetInfo(id);
			return Option.none();
		});
	});

	readonly nameOfNowPlaying = computed<Option<string>>(() => this.assetInfoOfNowPlaying().map(({ Name }) => Name));

	readonly isMuted = atom(false);
	private toFade = new WeakSet<Sound>();

	readonly transitionTime = atom(3);
	// readonly transitionEasingStyle = atom<Enum.EasingStyle>(Enum.EasingStyle.Linear);
	// readonly transitionEasingDirection = atom<Enum.EasingDirection>(Enum.EasingDirection.Out);

	// private transitionTweenInfo = computed(
	// 	() => new TweenInfo(this.transitionTime(), this.transitionEasingStyle(), this.transitionEasingDirection()),
	// );

	constructor(private characterController: CharacterController) {}

	private priorityOf(zone: Instance): number {
		return zone.GetAttribute("Priority") || 0;
	}

	onStart(): void {
		addMechanicBinding("@core/BackgroundMusicController/setTransitionTime", (time) =>
			this.transitionTime(ty.Number.CastOrError(time)),
		);

		// const EasingStyle = ty.Predicate(t.enum(Enum.EasingStyle)).Nicknamed("Enum.EasingStyle");
		// addMechanicBinding("@core/BackgroundMusicController/setTransitionEasingStyle", (style) =>
		// 	this.transitionEasingStyle(EasingStyle.CastOrError(style)),
		// );

		// const EasingDirection = ty.Predicate(t.enum(Enum.EasingDirection)).Nicknamed("Enum.EasingDirection");
		// addMechanicBinding("@core/BackgroundMusicController/transitionEasingDirection", (style) =>
		// 	this.transitionEasingDirection(EasingDirection.CastOrError(style)),
		// );

		effect(() => trace("Now playing", this.nameOfNowPlaying()));
	}

	onPreRender(dt: number): void {
		const nowPlaying = this.nowPlaying();
		if (this.isMuted() && nowPlaying) nowPlaying.Volume = 0;

		const root = this.characterController.getMaybeRoot();
		if (!root) return;

		const loadedZones = CollectionService.GetTagged(LOADED_ZONE_TAG);

		let prioritizedZone: Maybe<BackgroundMusicZoneInstance>;
		for (const zone of loadedZones) {
			if (BackgroundMusicZoneInstance(zone)) {
				for (const part of zone.GetDescendants()) {
					const prioritize =
						this.priorityOf(zone) > (prioritizedZone ? this.priorityOf(prioritizedZone) : -math.huge);
					if (prioritize && part.IsA("BasePart") && isPointInBounds(root.CFrame, part.CFrame, part.Size)) {
						prioritizedZone = zone;
						break;
					}
				}
			}
		}

		const prioritizedSound = prioritizedZone ? prioritizedZone.Sound : this.defaultSound();
		if (nowPlaying !== prioritizedSound) {
			this.lastPlaying(nowPlaying);
			if (nowPlaying) this.toFade.add(nowPlaying);
		}

		this.nowPlaying(prioritizedSound);
		if (prioritizedSound && !prioritizedSound.Playing) prioritizedSound.Play();

		const lastPlaying = this.lastPlaying();
		for (const sound of this.toFade) {
			const ogVolume = sound.GetAttribute("OriginalVolume") as number;
			sound.Volume -= (ogVolume / this.transitionTime()) * dt;
			sound.Volume = math.max(0, sound.Volume);
			if (sound.Volume <= 0) {
				sound.Stop();
				this.toFade.delete(sound);
				if (lastPlaying === sound) this.lastPlaying(undefined);
			}
		}

		if (prioritizedSound && !lastPlaying) {
			const ogVolume = prioritizedSound.GetAttribute("OriginalVolume") as number;
			prioritizedSound.Volume += (ogVolume / this.transitionTime()) * dt;
			prioritizedSound.Volume = math.min(ogVolume, prioritizedSound.Volume);
		}
	}
}
