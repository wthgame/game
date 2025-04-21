// import { Controller, OnStart } from "@flamework/core";
// import { useEventListener } from "@rbxts/pretty-vide-utils";
// import { CollectionService, Players, RunService, Stats } from "@rbxts/services";
// import Vide, { mount, source } from "@rbxts/vide";
// import { useAtom } from "@rbxts/vide-charm";
// import { ButtonStyle } from "client/ui/components/Button";
// import { Text, TextStyle } from "client/ui/components/Text";
// import { TriangularButton } from "client/ui/components/TriangularButton";
// import { CODE_NAME, REAL_NAME, VERSION } from "shared/constants/common";
// import { CharacterController } from "./CharacterController";
// import { MainViewController } from "./MainViewController";
// import { TowerRunController } from "./TowerRunController";

// @Controller()
// export class DebugOverlayController implements OnStart {
// 	constructor(
// 		private mainViewController: MainViewController,
// 		private characterController: CharacterController,
// 		private towerController: TowerRunController,
// 	) {}

// 	onStart(): void {
// 		mount(() => {
// 			const memoryMegabytes = source(0);
// 			const delta = source(0);
// 			const fps = source(0);
// 			const humanoidRootPartPosition = source(Vector3.zero);

// 			let lastIteration: number;
// 			let start = os.clock();
// 			const frameUpdateTable = new Map<number, number>();

// 			useEventListener(RunService.PostSimulation, () => {
// 				lastIteration = os.clock();

// 				for (const index of $range(frameUpdateTable.size(), 1, -1)) {
// 					if (frameUpdateTable.get(index)! >= lastIteration - 1) {
// 						frameUpdateTable.set(index + 1, frameUpdateTable.get(index)!);
// 					} else {
// 						frameUpdateTable.delete(index + 1);
// 					}
// 				}

// 				frameUpdateTable.set(1, lastIteration);
// 				fps(
// 					math.floor(
// 						os.clock() - start >= 1
// 							? frameUpdateTable.size()
// 							: frameUpdateTable.size() / (os.clock() - start),
// 					),
// 				);
// 			});

// 			useEventListener(RunService.RenderStepped, (dlt) => {
// 				memoryMegabytes(Stats.GetTotalMemoryUsageMb());

// 				const root = this.characterController.getMaybeRoot();
// 				if (root) {
// 					humanoidRootPartPosition(root.Position);
// 				}
// 			});

// 			let layoutOrder = 1;

// 			const currentTower = useAtom(this.towerController.currentTower);

// 			return (
// 				<screengui Name="DebugOverlay" ResetOnSpawn={false}>
// 					<frame Size={UDim2.fromScale(1, 1)} BackgroundTransparency={1}>
// 						<uilistlayout
// 							FillDirection={Enum.FillDirection.Vertical}
// 							VerticalAlignment={Enum.VerticalAlignment.Bottom}
// 							HorizontalAlignment={Enum.HorizontalAlignment.Left}
// 							SortOrder={Enum.SortOrder.LayoutOrder}
// 						/>
// 						<Text text="Dev Teleporters:" textStyle={TextStyle.Text} layoutOrder={layoutOrder++} />
// 						{CollectionService.GetTagged("DevTeleporter")
// 							.filter((v): v is BasePart => v.IsA("BasePart"))
// 							.sort((lhs, rhs) => lhs.Name < rhs.Name)
// 							.map((v) => (
// 								<TriangularButton
// 									buttonStyle={ButtonStyle.Primary}
// 									buttonLabel={v.Name}
// 									layoutOrder={layoutOrder++}
// 									onClick={() => {
// 										Players.LocalPlayer.Character?.PivotTo(v.CFrame);
// 									}}
// 								/>
// 							))}
// 						<Text
// 							text={() => `${REAL_NAME} (${CODE_NAME}) v${VERSION.toString()}`}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<Text
// 							text={() =>
// 								`XYZ: ${math.round(humanoidRootPartPosition().X * 10) / 10} ${math.round(humanoidRootPartPosition().Y * 10) / 10} ${math.round(humanoidRootPartPosition().Z * 10) / 10}`
// 							}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<Text
// 							text={() => `Framerate: ${math.round(fps())}fps`}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<Text
// 							text={() => `Memory: ${math.round(memoryMegabytes())}mb`}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<Text
// 							text={() => `Today is ${DateTime.now().FormatUniversalTime("LL", "vi-vn")} in Vietnam`}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<Text
// 							text={() =>
// 								currentTower() ? `Current tower: ${currentTower()!.title}` : "No tower running"
// 							}
// 							textStyle={TextStyle.Text}
// 							layoutOrder={layoutOrder++}
// 						/>
// 						<TriangularButton
// 							buttonStyle={ButtonStyle.Primary}
// 							buttonLabel="Toggle Main View"
// 							layoutOrder={layoutOrder++}
// 							onClick={() =>
// 								this.mainViewController.isMainViewOpen(!this.mainViewController.isMainViewOpen())
// 							}
// 						/>
// 					</frame>
// 				</screengui>
// 			);
// 		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
// 	}
// }
