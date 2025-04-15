import { Controller, OnStart } from "@flamework/core";
import { useEventListener } from "@rbxts/pretty-vide-utils";
import { Players, RunService, Stats } from "@rbxts/services";
import Vide, { mount, source } from "@rbxts/vide";
import { DebugOverlay } from "client/ui/views/DebugOverlay";
import { CODE_NAME, REAL_NAME, VERSION } from "shared/constants/common";
import { CharacterController } from "./CharacterController";
import { MainViewController } from "./MainViewController";

@Controller()
export class DebugOverlayController implements OnStart {
	constructor(
		private mainViewController: MainViewController,
		private characterController: CharacterController,
	) {}

	onStart(): void {
		mount(() => {
			const memoryMegabytes = source(0);
			const delta = source(0);
			const fps = source(0);
			const humanoidRootPartPosition = source(Vector3.zero);

			let lastIteration: number;
			let start = os.clock();
			const frameUpdateTable = new Map<number, number>();

			useEventListener(RunService.PostSimulation, () => {
				lastIteration = os.clock();

				for (const index of $range(frameUpdateTable.size(), 1, -1)) {
					if (frameUpdateTable.get(index)! >= lastIteration - 1) {
						frameUpdateTable.set(index + 1, frameUpdateTable.get(index)!);
					} else {
						frameUpdateTable.delete(index + 1);
					}
				}

				frameUpdateTable.set(1, lastIteration);
				fps(
					math.floor(
						os.clock() - start >= 1
							? frameUpdateTable.size()
							: frameUpdateTable.size() / (os.clock() - start),
					),
				);
			});

			useEventListener(RunService.RenderStepped, (dlt) => {
				memoryMegabytes(Stats.GetTotalMemoryUsageMb());

				const root = this.characterController.getMaybeRoot();
				if (root) {
					humanoidRootPartPosition(root.Position);
				}
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
						humanoidRootPartPosition={humanoidRootPartPosition}
						toggleMainView={() => {
							this.mainViewController.isMainViewOpen(!this.mainViewController.isMainViewOpen());
						}}
					/>
				</screengui>
			);
		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
	}
}
