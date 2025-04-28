import { Controller, OnStart } from "@flamework/core";
import { atom } from "@rbxts/charm";
import { Players, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import Vide, { Derivable, mount, read } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { LightingController, LightingPriority } from "core/client/controllers/LightingController";
import { MechanicController } from "core/client/controllers/MechanicController";
import { trace } from "core/shared/log";
import { areas } from "game/client/net";
import { ButtonStyle } from "game/client/ui/components/Button";
import { Text, TextStyle } from "game/client/ui/components/Text";
import { TriangularButton } from "game/client/ui/components/TriangularButton";
import { palette } from "game/client/ui/palette";
import { px } from "game/client/ui/px";
import { AreaInfo, AREAS } from "game/shared/areas";

export interface AreaViewProps {
	areas: Derivable<AreaInfo[]>;
	onAreaSelected: (area: AreaInfo) => void;
}

export function AreaView({ areas, onAreaSelected }: AreaViewProps) {
	let layoutOrder = 1;
	return (
		<frame BackgroundColor3={() => palette("bg")} Size={UDim2.fromScale(1, 1)} Name="AreaView">
			<uilistlayout
				VerticalAlignment="Center"
				HorizontalAlignment="Center"
				SortOrder="LayoutOrder"
				Padding={() => new UDim(0, px(4))}
			/>
			<Text text="Select an area to load:" textStyle={TextStyle.Text} layoutOrder={layoutOrder++} />
			<Text
				text="Later this will be replaced with a proper title screen."
				textStyle={TextStyle.Label}
				layoutOrder={layoutOrder++}
			/>
			{() =>
				read(areas).map((a) => (
					<TriangularButton
						buttonStyle={ButtonStyle.Primary}
						buttonLabel={a.title}
						onClick={() => onAreaSelected(a)}
						layoutOrder={layoutOrder++}
					/>
				))
			}
		</frame>
	);
}

@Controller()
export class AreaController implements OnStart {
	isLoadingArea = false;
	isLoaded = atom(false);

	constructor(
		private mechanicController: MechanicController,
		private lightingController: LightingController,
	) {}

	onStart(): void {
		mount(() => {
			const isLoaded = useAtom(this.isLoaded);

			return (
				<screengui Name="AreaView" ResetOnSpawn={false} Enabled={() => !isLoaded()} IgnoreGuiInset>
					<AreaView areas={AREAS} onAreaSelected={(a) => this.loadArea(a)} />
				</screengui>
			);
		}, Players.LocalPlayer.PlayerGui);
	}

	private async loadAreaMechanics(trove: Trove, mechanics: Instance) {
		trace("Loading mechanics");
		await this.mechanicController.loadMechanicsFromParent(trove, mechanics);

		this.isLoaded(true);
		this.isLoadingArea = false;

		trace("Finished loading mechanics");
	}

	// private async setAreaServices(trove: Trove, areaInstance: Instance) {
	// 	trace("Setting area services");
	// 	const services = areaInstance.FindFirstChild("Services");
	// 	if (services) {
	// 		for (const s of services.GetChildren()) {
	// 			const realService = game.GetService(s.Name as never);
	// 			for (const [property, value] of pairs(s.GetAttributes())) {
	// 				(realService as Map<unknown, unknown>).set(property, value);
	// 			}
	// 			for (const child of s.GetChildren()) trove.add(child).Parent = realService;
	// 		}
	// 	}
	// 	trace("Finished setting area services");
	// }

	async loadArea(area: AreaInfo) {
		if (this.isLoadingArea) return;
		this.isLoadingArea = true;

		trace(`Requesting to load area ${area.name}`);

		const areaInstance = areas.loadArea.invoke(area.name).expect();

		trace("Got area");
		const clone = areaInstance.Clone();
		clone.Parent = Workspace;

		areaInstance.Destroy();
		areas.confirmAreaLoaded.fire();

		const trove = new Trove();

		const lighting = clone.FindFirstChild("Lighting");
		if (lighting) {
			trace("Setting area lighting");
			this.lightingController.setLightingAtPriority(lighting.GetAttributes() as never, LightingPriority.Area);
		}

		await this.loadAreaMechanics(trove, clone.FindFirstChild("Mechanics")!);

		trace("Finished loading area");

		return trove;
	}
}
