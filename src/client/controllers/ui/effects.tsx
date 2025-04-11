// import { Controller, OnInit, OnStart } from "@flamework/core";
// import { Lazy } from "@rbxts/lazy";
// import { useDebounceEffect } from "@rbxts/pretty-vide-utils";
// import { Debris, Players, StarterGui, TweenService } from "@rbxts/services";
// import { effect, mount } from "@rbxts/vide";
// import assets from "shared/assets";
// import { useHumanoid } from "shared/utils/use-humanoid";

// export interface FlashBorderGlowProps {
// 	color: Color3;
// 	durationSeconds: number;
// 	transparency?: number;
// 	sliceScale?: number;
// }

// export const BORDER_GLOW_SLICE_CENTER = new Rect(new Vector2(100, 100), new Vector2(412, 412));

// @Controller()
// export class EffectController implements OnInit, OnStart {
// 	private effectView = new Lazy(() => {
// 		const effectView = new Instance("ScreenGui");
// 		effectView.Name = "EffectView";
// 		effectView.ResetOnSpawn = false;
// 		effectView.IgnoreGuiInset = true;
// 		effectView.Parent = Players.LocalPlayer.PlayerGui;
// 		return effectView;
// 	});

// 	// private fullFrameTemplate = new Lazy(() => {
// 	// 	const fullFrameTemplate = new Instance("Frame");
// 	// 	fullFrameTemplate.BorderSizePixel = 0;
// 	// 	fullFrameTemplate.BackgroundTransparency = 1;
// 	// 	fullFrameTemplate.Size = UDim2.fromScale(1, 1);
// 	// 	fullFrameTemplate.Visible = false;
// 	// 	fullFrameTemplate.Parent = this.effectView.getValue();
// 	// 	return fullFrameTemplate;
// 	// });

// 	private createBorderGlow() {
// 		const borderGlow = new Instance("ImageLabel");
// 		borderGlow.Name = "BorderGlow";
// 		borderGlow.BorderSizePixel = 0;
// 		borderGlow.BackgroundTransparency = 1;
// 		borderGlow.Image = assets.ui.borderGlow;
// 		borderGlow.ImageTransparency = 0;
// 		borderGlow.ScaleType = Enum.ScaleType.Slice;
// 		borderGlow.SliceCenter = BORDER_GLOW_SLICE_CENTER;
// 		borderGlow.SliceScale = 0;
// 		borderGlow.Size = UDim2.fromScale(1, 1);
// 		borderGlow.Parent = this.effectView.getValue();
// 		return borderGlow;
// 	}

// 	onInit(): void {
// 		this.effectView.getValue();
// 	}

// 	onStart(): void {
// 		StarterGui.SetCoreGuiEnabled("Health", false);
// 		mount(() => {
// 			const humanoid = useHumanoid();
// 			effect((connection: Maybe<RBXScriptConnection>) => {
// 				if (connection) connection.Disconnect();

// 				const humanoidNow = humanoid();
// 				if (humanoidNow) {
// 					let oldHealth = humanoidNow.Health;
// 					return humanoidNow.HealthChanged.Connect((newHealth) => {
// 						const difference = oldHealth - newHealth;

// 						if (difference > 0) {
// 							this.flashBorderGlow({
// 								color: new Color3(1, 0, 0),
// 								durationSeconds: 0.5,
// 								transparency: 0,
// 							});
// 						}

// 						oldHealth = newHealth;
// 					});
// 				}

// 				return undefined;
// 			}, undefined);
// 		});
// 	}

// 	flashBorderGlow({ color, durationSeconds, transparency = 0, sliceScale = 1 }: FlashBorderGlowProps) {
// 		const borderGlow = this.createBorderGlow();
// 		borderGlow.ImageTransparency = transparency;
// 		borderGlow.ImageColor3 = color;

// 		const tween = TweenService.Create(
// 			borderGlow,
// 			new TweenInfo(durationSeconds, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
// 			{
// 				SliceScale: sliceScale,
// 				ImageTransparency: 1,
// 			},
// 		);

// 		tween.Completed.Once(() => {
// 			borderGlow.Destroy();
// 			tween.Destroy();
// 		});

// 		Debris.AddItem(borderGlow, durationSeconds + 0.5);

// 		tween.Play();
// 	}
// }
