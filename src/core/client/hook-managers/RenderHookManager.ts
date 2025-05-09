import { Controller, Modding, OnStart } from "@flamework/core";
import { RunService } from "@rbxts/services";

export interface OnPreRender {
	onPreRender(dt: number): void;
}

export interface OnPreAnimation {
	onPreAnimation(dt: number): void;
}

function callPreRender(listener: OnPreRender, dt: number) {
	listener.onPreRender(dt);
}

function callPreAnimation(listener: OnPreAnimation, dt: number) {
	listener.onPreAnimation(dt);
}

@Controller()
export class RenderHookManager implements OnStart {
	private preRender = new Set<OnPreRender>();
	private preAnimation = new Set<OnPreAnimation>();

	onStart(): void {
		Modding.onListenerAdded<OnPreRender>((object) => this.preRender.add(object));
		Modding.onListenerRemoved<OnPreAnimation>((object) => this.preAnimation.delete(object));
		RunService.PreRender.Connect((dt) => {
			for (const listener of this.preRender) task.spawn(callPreRender, listener, dt);
		});
		RunService.PreAnimation.Connect((dt) => {
			for (const listener of this.preAnimation) task.spawn(callPreAnimation, listener, dt);
		});
	}
}
