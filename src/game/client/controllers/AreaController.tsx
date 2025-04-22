import { Controller, OnStart } from "@flamework/core";
import { atom } from "@rbxts/charm";
import { Players, Workspace } from "@rbxts/services";
import { Trove } from "@rbxts/trove";
import Vide, { Derivable, mount, read } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
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

	async loadArea(area: AreaInfo) {
		if (this.isLoadingArea) return;
		this.isLoadingArea = true;

		trace(`Requesting to load area ${area.name}`);

		const inst = areas.loadArea.invoke(area.name).expect();

		trace("Got area");

		trace("Cloning");
		const clone = inst.Clone();
		trace("Cloned");
		clone.Parent = Workspace;
		print(clone);
		print(clone.WaitForChild("Mechanics"));

		inst.Destroy();

		// i have no fucking clue why ts not working ????
		task.wait(1);

		const trove = new Trove();

		trace("Loading mechanics");
		await this.mechanicController.loadMechanicsFromParent(trove, clone.WaitForChild("Mechanics"));
		trace("Finished loading mechanics");

		this.isLoaded(true);
		this.isLoadingArea = false;

		areas.confirmAreaLoaded.fire();

		return trove;
	}
}
