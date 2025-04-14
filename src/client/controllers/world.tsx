import { Controller, OnStart } from "@flamework/core";
import { atom } from "@rbxts/charm";
import { Players, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import Vide, { Derivable, mount, read } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { areas } from "client/net";
import { ButtonStyle } from "client/ui/components/Button";
import { Text, TextStyle } from "client/ui/components/Text";
import { TriangularButton } from "client/ui/components/TriangularButton";
import { palette } from "client/ui/palette";
import { px } from "client/ui/px";
import { Area, AREAS } from "shared/constants/game";
import { trace } from "shared/log";
import { MechanicController } from "./mechanics";

export interface AreaViewProps {
	areas: Derivable<Area[]>;
	onAreaSelected: (area: Area) => void;
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
export class WorldController implements OnStart {
	isLoadingArea = false;
	isLoaded = atom(false);

	constructor(private mechanicController: MechanicController) {}

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

	loadArea(area: Area) {
		if (this.isLoadingArea) return;
		this.isLoadingArea = true;

		trace(`Requesting to load area ${area.name}`);

		const inst = areas.loadArea.invoke(area.name).expect();

		const clone = inst.Clone();
		clone.Parent = Workspace;

		inst.Destroy();

		const trove = new Trove();

		this.mechanicController.loadMechanicsFromParent(trove, clone.WaitForChild("Mechanics"));

		this.isLoaded(true);
		this.isLoadingArea = false;

		areas.confirmAreaLoaded.fire();

		return trove;
	}
}
