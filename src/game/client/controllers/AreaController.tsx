import { Controller, OnStart } from "@flamework/core";
import { atom } from "@rbxts/charm";
import { Players, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import Vide, { Derivable, mount, read } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { LightingController, LightingPriority } from "core/client/controllers/LightingController";
import { MechanicController } from "core/client/controllers/MechanicController";
// import { ButtonStyle } from "core/client/_ui/components/Button";
// import { Text, TextStyle } from "core/client/_ui/components/Text";
// import { TriangularButton } from "core/client/_ui/components/TriangularButton";
import { Text } from "core/client/ui/components/Text";
import { PrimaryTriangularButton } from "core/client/ui/components/TriangularButton";
import { palette } from "core/client/ui/palette";
import { rem, useRem } from "core/client/ui/rem";
import { fonts } from "core/client/ui/styles";
import { trace } from "core/shared/log";
import { areas } from "game/client/net";
import { AreaInfo, AREAS } from "game/shared/areas";

export interface AreaViewProps {
	areas: Derivable<AreaInfo[]>;
	onAreaSelected: (area: AreaInfo) => void;
}

export function AreaView({ areas, onAreaSelected }: AreaViewProps) {
	let layoutOrder = 1;
	return (
		<frame BackgroundColor3={() => palette("crust")} Size={UDim2.fromScale(1, 1)} Name="AreaView">
			<uilistlayout
				VerticalAlignment="Center"
				HorizontalAlignment="Center"
				SortOrder="LayoutOrder"
				Padding={() => new UDim(0, rem(1))}
			/>
			<Text
				text="Select an area to load:"
				font={fonts.serif.regular}
				textColor={new Color3(1, 1, 1)}
				textSize={() => rem(1)}
				layoutOrder={layoutOrder++}
			/>
			<Text
				text="Later this will be replaced with a proper title screen."
				font={fonts.serif.regular}
				textColor={new Color3(1, 1, 1)}
				textSize={() => rem(1)}
				layoutOrder={layoutOrder++}
			/>
			{() =>
				read(areas).map((a) => (
					<PrimaryTriangularButton
						buttonLabel={a.title}
						labelSize={() => rem(1)}
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
			useRem();
			const isLoaded = useAtom(this.isLoaded);

			return (
				<screengui Name="AreaView" ResetOnSpawn={false} Enabled={() => !isLoaded()} IgnoreGuiInset>
					<AreaView areas={AREAS} onAreaSelected={(a) => this.loadArea(a)} />
				</screengui>
			);
		}, Players.LocalPlayer.PlayerGui);
	}

	private async loadAreaMechanics(trove: Trove, mechanics: Instance) {}

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

		trace("Loading mechanics");
		await this.mechanicController.loadMechanicsFromParent(trove, clone.WaitForChild("Mechanics"));
		trace("Finished loading mechanics");

		trace("Finished loading area");

		this.isLoaded(true);
		this.isLoadingArea = false;

		return trove;
	}
}
