import { Controller, OnStart } from "@flamework/core";
import { Players } from "@rbxts/services";
import Vide, { effect, mount, Source, source } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { debug } from "core/shared/log";
import { TowerRunView } from "../ui/views/TowerRunView";
import { TowerRunController } from "./TowerRunController";

@Controller()
export class MenuController implements OnStart {
	isMenuOpen: Source<boolean> = source(false);

	constructor(private towerRunController: TowerRunController) {}

	onStart(): void {
		mount(() => {
			const elapsedTime = useAtom(this.towerRunController.elapsedTime);
			const currentTower = useAtom(this.towerRunController.currentTower);

			effect(() => debug(`Menu ${this.isMenuOpen() ? "is" : "is not"} open`));
			return (
				<>
					<screengui Name="Menu"></screengui>
					<screengui Name="TowerRunTimer" IgnoreGuiInset>
						<TowerRunView time={elapsedTime} info={currentTower} />
					</screengui>
				</>
			);
		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
	}
}
