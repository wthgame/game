import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import { Players } from "@rbxts/services";
import { mount } from "@rbxts/vide";

@Controller()
export class EffectController implements OnInit {
	private effectView = new Lazy(() => {
		const effectView = new Instance("ScreenGui");
		effectView.Name = "EffectView";
		effectView.ResetOnSpawn = false;
		effectView.Parent = Players.LocalPlayer.PlayerGui;
		return effectView;
	});

	private frame = new Lazy(() => {
		const frame = new Instance("Frame");
		frame.BorderSizePixel = 1;
		frame.BackgroundTransparency = 1;
		frame.Size = UDim2.fromScale(1, 1);
		frame.Visible = false;
		frame.Parent = this.effectView.getValue();
		return frame;
	});

	private borderGlow = new Lazy(() => {
		const borderGlow = new Instance("ImageLabel");
		borderGlow.Name = "BorderFlash";
		borderGlow.BorderSizePixel = 1;
		borderGlow.BackgroundTransparency = 1;
		borderGlow.Size = UDim2.fromScale(1, 1);
		borderGlow.Visible = false;
		borderGlow.Parent = this.effectView.getValue();
		return borderGlow;
	});

	onInit(): void {
		this.effectView.getValue();
		this.frame.getValue();
		this.borderGlow.getValue();
	}
}
