import { Controller, OnStart } from "@flamework/core";
import { atom } from "@rbxts/charm";
import { Players, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import Vide, { Derivable, mount, read } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { BackgroundMusicController } from "core/client/controllers/BackgroundMusicController";
import { LightingController, LightingPriority } from "core/client/controllers/LightingController";
import { MechanicController } from "core/client/controllers/MechanicController";
import { Text } from "core/client/ui/components/Text";
import { PrimaryTriangularButton } from "core/client/ui/components/TriangularButton";
import { palette } from "core/client/ui/palette";
import { rem, useRem } from "core/client/ui/rem";
import { fonts } from "core/client/ui/styles";
import { LogBenchmark } from "core/shared/decorators";
import { createLogger } from "core/shared/logger";
import { areas } from "game/client/net";
import { AreaInfo, AreaInstance, AREAS } from "game/shared/areas";

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
	private logger = createLogger("AreaController");

	isLoadingArea = false;
	isLoaded = atom(false);

	constructor(
		private mechanicController: MechanicController,
		private lightingController: LightingController,
		private backgroundMusicController: BackgroundMusicController,
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

	@LogBenchmark()
	async loadArea(area: AreaInfo) {
		if (this.isLoadingArea) return;
		this.isLoadingArea = true;

		this.logger.trace(`Requesting to load area ${area.name}`);

		const areaInstance = areas.loadArea.invoke(area.name).expect() as AreaInstance;

		this.logger.trace("Got area");
		const clone = areaInstance.Clone();
		clone.Parent = Workspace;

		areaInstance.Destroy();
		areas.confirmAreaLoaded.fire();

		const trove = new Trove();
		trove.add(clone);

		const lighting = clone.FindFirstChild("Lighting");
		if (lighting) {
			this.logger.trace("Setting area lighting");
			this.lightingController.setLightingAtPriority(lighting.GetAttributes() as never, LightingPriority.Area);
		}

		this.logger.trace("Setting default background music");
		this.backgroundMusicController.defaultSound(clone.DefaultBackgroundMusic);
		this.backgroundMusicController.consumeMusicZones(trove, clone.BackgroundMusicZones);

		this.logger.trace("Loading mechanics");
		await this.mechanicController.loadMechanicsFromParent(trove, clone.WaitForChild("Mechanics"));
		this.logger.trace("Finished loading mechanics");

		this.logger.trace("Finished loading area");

		this.isLoaded(true);
		this.isLoadingArea = false;

		return trove;
	}
}
