import { Controller, OnStart } from "@flamework/core";
import { Players } from "@rbxts/services";
import Vide, { effect, mount, Source, source } from "@rbxts/vide";
import { debug } from "shared/log";

@Controller()
export class MainViewController implements OnStart {
	isMainViewOpen: Source<boolean>;

	constructor() {
		this.isMainViewOpen = source(false);
	}

	onStart(): void {
		mount(() => {
			effect(() => debug(`Main view ${this.isMainViewOpen() ? "is" : "is not"} open`));
			return <screengui Name="MainView"></screengui>;
		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
	}
}
