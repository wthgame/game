import { Controller, OnStart } from "@flamework/core";
import Vide, { mount, read, source } from "@rbxts/vide";
import { Players, RunService, Stats } from "@rbxts/services";
import { DebugOverlay } from "client/ui/views/DebugOverlay";
import { CODE_NAME, REAL_NAME, VERSION } from "shared/constants/common";
import { useEventListener } from "@rbxts/pretty-vide-utils";
import { MainViewController } from "./main-view";
import { debug } from "shared/log";
// import { scope } from "shared/scope";

@Controller()
export class DebugOverlayController implements OnStart {
	constructor(private mainViewController: MainViewController) {}

	onStart(): void {
		mount(() => {
			const memoryMegabytes = source(0);
			const delta = source(0);
			const fps = source(0);

			useEventListener(RunService.PreRender, (dlt) => {
				const framed = 1 / dlt;
				fps(math.floor(((1 / delta() + framed) / 2) * 10) / 10);
				delta(dlt);

				memoryMegabytes(Stats.GetTotalMemoryUsageMb());
			});

			return (
				<screengui Name="DebugOverlay" ResetOnSpawn={false}>
					<DebugOverlay
						fps={fps}
						memoryMegabytes={memoryMegabytes}
						today={DateTime.now()}
						realname={REAL_NAME}
						codename={CODE_NAME}
						version={VERSION}
						toggleMainView={() => {
							debug("TOGGLING");
							this.mainViewController.isMainViewOpen(!this.mainViewController.isMainViewOpen());
						}}
					/>
				</screengui>
			);
		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
	}
}
