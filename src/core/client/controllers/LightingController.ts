import { Controller, OnInit, OnStart } from "@flamework/core";
import { atom, subscribe } from "@rbxts/charm";
import { Lazy } from "@rbxts/lazy";
import ty from "@rbxts/libopen-ty";
import Make from "@rbxts/make";
import { Lighting } from "@rbxts/services";
import { addMechanicBinding } from "./MechanicController/bindings";

export enum LightingPriority {
	/// Base lighting
	Base = -2,
	/// Lighting for areas via Configuration.Lighting
	Area = -1,
	/// Lighting for towers via LightingChangers. For convinience, this begins
	/// at 0.
	Tower = 0,
}

interface LightingProps<I extends Instance> {
	key: string;
	instance: Lazy<I>;
	checks: { [K in Extract<keyof I, string>]?: ty.Def<I[K]> };
}

const LIGHTING_PROPS = {
	Lighting: {
		key: "Lighting",
		instance: new Lazy(() => Lighting),
		checks: {
			Brightness: ty.Number,
			Ambient: ty.Typeof("Color3"),
			OutdoorAmbient: ty.Typeof("Color3"),
			ColorShift_Top: ty.Typeof("Color3"),
			ColorShift_Bottom: ty.Typeof("Color3"),
			FogColor: ty.Typeof("Color3"),
			FogStart: ty.Number,
			FogEnd: ty.Number,
			ExposureCompensation: ty.Number,
			EnvironmentDiffuseScale: ty.Number,
			EnvironmentSpecularScale: ty.Number,
			ClockTime: ty.Number,
			GeographicLatitude: ty.Number,
		},
	},
	Atmosphere: {
		key: "Atmosphere",
		instance: new Lazy(() => Make("Atmosphere", {})),
		checks: {
			Color: ty.Typeof("Color3"),
			Decay: ty.Typeof("Color3"),
			Glare: ty.Number,
			Haze: ty.Number,
			Density: ty.Number,
			Offset: ty.Number,
		},
	},
	Sky: {
		key: "Sky",
		instance: new Lazy(() =>
			Make("Sky", {
				Parent: Lighting,
				SkyboxBk: "rbxassetid://0",
				SkyboxFt: "rbxassetid://0",
				SkyboxLf: "rbxassetid://0",
				SkyboxRt: "rbxassetid://0",
				SkyboxUp: "rbxassetid://0",
				SkyboxDn: "rbxassetid://0",
				SunTextureId: "rbxassetid://0",
				SunAngularSize: 0,
				MoonTextureId: "rbxassetid://0",
				MoonAngularSize: 0,
				CelestialBodiesShown: false,
			}),
		),
		checks: {
			SkyboxBk: ty.String,
			SkyboxFt: ty.String,
			SkyboxLf: ty.String,
			SkyboxRt: ty.String,
			SkyboxUp: ty.String,
			SkyboxDn: ty.String,
			SunTextureId: ty.String,
			SunAngularSize: ty.Number,
			MoonTextureId: ty.String,
			MoonAngularSize: ty.Number,
			CelestialBodiesShown: ty.Boolean,
			StarCount: ty.Number,
		},
	},
	BlurEffect: {
		key: "BlurEffect",
		instance: new Lazy(() => Make("BlurEffect", { Size: 0, Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			Size: ty.Number,
		},
	},
	BloomEffect: {
		key: "BloomEffect",
		instance: new Lazy(() => Make("BloomEffect", { Intensity: 1, Size: 24, Threshold: 2, Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			Intensity: ty.Number,
			Size: ty.Number,
			Threshold: ty.Number,
		},
	},
	DepthOfFieldEffect: {
		key: "DepthOfFieldEffect",
		instance: new Lazy(() => Make("DepthOfFieldEffect", { NearIntensity: 0, FarIntensity: 0, Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			FarIntensity: ty.Number,
			FocusDistance: ty.Number,
			InFocusRadius: ty.Number,
			NearIntensity: ty.Number,
		},
	},
	ColorCorrectionEffect: {
		key: "ColorCorrectionEffect",
		instance: new Lazy(() => Make("ColorCorrectionEffect", { Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			Brightness: ty.Number,
			Contrast: ty.Number,
			Saturation: ty.Number,
			TintColor: ty.Typeof("Color3"),
		},
	},
	ColorGradingEffect: {
		key: "ColorGradingEffect",
		instance: new Lazy(() => Make("ColorGradingEffect", { Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			TonemapperPreset: ty
				.Predicate(
					(x): x is Enum.TonemapperPreset => typeIs(x, "EnumItem") && x.EnumType === Enum.TonemapperPreset,
				)
				.Nicknamed("Enum.TonemapperPreset"),
		},
	},
	SunRays: {
		key: "SunRaysEffect",
		instance: new Lazy(() => Make("SunRaysEffect", { Parent: Lighting })),
		checks: {
			Enabled: ty.Boolean,
			Intensity: ty.Number,
			Spread: ty.Number,
		},
	},
} as const;

// NOTE: if celina didnt make me go insane this will
type LightingAttributeKey<ClassName extends string, Property extends string> = `${ClassName}_${Property}`;
type AllLightingProps = typeof LIGHTING_PROPS;
type SingleLightingPropAsAttribute<T> =
	T extends LightingProps<infer I>
		? {
				[K in LightingAttributeKey<T["key"], string & keyof T["checks"]>]: K extends LightingAttributeKey<
					T["key"],
					infer P extends string & keyof T["checks"]
				>
					? ty.Static<T["checks"][P]>
					: never;
			}
		: never;
type LightingPropsAsAttributes = UnionToIntersection<
	SingleLightingPropAsAttribute<AllLightingProps[keyof AllLightingProps]>
>;

export interface LightingAttributes extends Partial<LightingPropsAsAttributes> {
	Atmosphere_Enabled?: boolean;
}

const BASE_LIGHTING_ATTRIBUTES: LightingAttributes = {
	Lighting_Brightness: 1,
	Lighting_Ambient: new Color3(0.5, 0.5, 0.5),
	Lighting_OutdoorAmbient: new Color3(0.5, 0.5, 0.5),
	Lighting_ColorShift_Top: new Color3(1, 1, 1),
	Lighting_ColorShift_Bottom: new Color3(0, 0, 0),
	Lighting_FogColor: new Color3(1, 1, 1),
	Lighting_FogStart: 0,
	Lighting_ExposureCompensation: 0,
	Lighting_EnvironmentDiffuseScale: 0,
	Lighting_EnvironmentSpecularScale: 0,
	Lighting_FogEnd: math.huge,
	Lighting_ClockTime: 12,
	Lighting_GeographicLatitude: 0,
	Sky_SkyboxBk: "",
	Sky_SkyboxFt: "",
	Sky_SkyboxLf: "",
	Sky_SkyboxRt: "",
	Sky_SkyboxUp: "",
	Sky_SkyboxDn: "",
	Sky_SunTextureId: "",
	Sky_SunAngularSize: 0,
	Sky_MoonTextureId: "",
	Sky_MoonAngularSize: 0,
	Sky_CelestialBodiesShown: false,
	Sky_StarCount: 0,
	Atmosphere_Enabled: false,
	BlurEffect_Enabled: false,
	BlurEffect_Size: 0,
	BloomEffect_Enabled: false,
	BloomEffect_Intensity: 0,
	BloomEffect_Size: 0,
	BloomEffect_Threshold: 0,
	DepthOfFieldEffect_Enabled: false,
	DepthOfFieldEffect_FarIntensity: 0,
	DepthOfFieldEffect_FocusDistance: 0,
	DepthOfFieldEffect_InFocusRadius: 0,
	DepthOfFieldEffect_NearIntensity: 0,
	SunRaysEffect_Enabled: false,
	SunRaysEffect_Intensity: 0,
	SunRaysEffect_Spread: 0,
};

interface Attribute {
	parent: LightingProps<Instance>;
	property: string;
	def: ty.Def<unknown>;
}

@Controller()
export class LightingController implements OnInit, OnStart {
	private attributeDefs = new Map<string, Attribute>();
	private currentAttributes = atom<LightingAttributes[]>([]);

	onInit(): void {
		this.currentAttributes((currentAttributes) => {
			currentAttributes = table.clone(currentAttributes);
			currentAttributes[LightingPriority.Base] = BASE_LIGHTING_ATTRIBUTES;
			return currentAttributes;
		});

		const attributeStructDefs: Record<string, ty.Def<unknown>> = {};
		for (const [, parent] of pairs(LIGHTING_PROPS) as never as Map<string, LightingProps<Instance>>) {
			parent.instance.getValue();
			for (const [property, def] of pairs(parent.checks) as never as Map<string, ty.Def<unknown>>) {
				const key = `${parent.key}_${property}`;
				this.attributeDefs.set(key, {
					parent,
					property,
					def,
				});
				attributeStructDefs[key] = def.Optional();
			}
		}

		subscribe(this.currentAttributes, (currentAttributes) => this.updateLightingAttributes(currentAttributes));

		attributeStructDefs.Atmosphere_Enabled = ty.Boolean.Optional();
		const LightingAttributes = ty
			// NOTE: unexhaustive so LightingChangers can have extra attributes
			.Struct({ exhaustive: false }, attributeStructDefs)
			.Nicknamed("LightingAttributes")
			.Retype<LightingAttributes>();

		const TowerLightingPriority = ty.Number.IntoDefault(LightingPriority.Tower);
		addMechanicBinding("setTowerLighting", async (attributes, priority) => {
			this.setLightingAtPriority(
				LightingAttributes.CastOrError(attributes),
				TowerLightingPriority.CastOrError(priority),
			);
		});
	}

	onStart(): void {
		this.updateLightingAttributes(this.currentAttributes());
	}

	// TODO: Atmosphere_Enabled is hardcoded right now, can we not do that?
	private updateLightingAttributes(currentAttributes: LightingAttributes[]) {
		interface AttributeToApply {
			priority: number;
			value: unknown;
			attribute: Attribute;
		}

		const attributesToApply = new Map<string, AttributeToApply>();

		function trySetAttribute(attributeName: string, value: unknown, priority: number, attribute: Attribute) {
			const existingValue = attributesToApply.get(attributeName);
			if (existingValue !== undefined && (existingValue.value === value || existingValue.priority > priority)) {
				return;
			}

			attributesToApply.set(attributeName, {
				priority,
				value,
				attribute,
			});
		}

		for (const [priority, attributes] of pairs(currentAttributes)) {
			for (const [attributeName, value] of pairs(attributes)) {
				const thisAttribute = this.attributeDefs.get(attributeName);

				if (!thisAttribute) {
					if (attributeName === "Atmosphere_Enabled") {
						// NOTE: it doesnt matter here
						trySetAttribute("Atmosphere_Enabled", value, priority, undefined as never);
					} else warn(`Invalid lighting attribute "${attributeName}" (internal bug?)`);
					continue;
				}

				const castValue = thisAttribute.def.Cast(value);

				if (castValue.some) trySetAttribute(attributeName, castValue.value, priority, thisAttribute);
				else warn(`Invalid type for lighting attribute "${attributeName}": ${castValue.reason}`);
			}
		}

		LIGHTING_PROPS.Atmosphere.instance.getValue().Parent = attributesToApply.get("Atmosphere_Enabled")
			? Lighting
			: undefined;

		attributesToApply.delete("Atmosphere_Enabled");

		for (const [, { attribute, value }] of attributesToApply) {
			(attribute.parent.instance.getValue() as any)[attribute.property] = value;
		}
	}

	setLightingAtPriority(attributes: LightingAttributes, priority: LightingPriority): void {
		this.currentAttributes((currentAttributes) => {
			// NOTE: fuck you roblox-ts for indexes
			currentAttributes = table.clone(currentAttributes);
			currentAttributes[priority - 1] = attributes;
			return currentAttributes;
		});
	}
}
