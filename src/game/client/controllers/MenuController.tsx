import { Controller, OnStart } from "@flamework/core";
import { Players } from "@rbxts/services";
import Vide, { effect, mount, Source, source } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { debug } from "core/shared/log";
// import { TowerRunView } from "../ui/views/TowerRunView";
import { useRem } from "core/client/ui/rem";
import { MenuButton } from "../ui/MenuButton";
import { RunInfo } from "../ui/RunInfo";
import { TowerRunController } from "./TowerRunController";

@Controller()
export class MenuController implements OnStart {
	isMenuOpen: Source<boolean> = source(false);

	constructor(private towerRunController: TowerRunController) {}

	onStart(): void {
		mount(() => {
			useRem();
			const elapsedTime = useAtom(this.towerRunController.elapsedTime);
			const currentTower = useAtom(this.towerRunController.currentTower);

			effect(() => debug(`Current tower: ${currentTower()}`));

			effect(() => debug(`Menu ${this.isMenuOpen() ? "is" : "is not"} open`));
			return (
				<>
					<screengui Name="Menu" DisplayOrder={2}></screengui>
					<screengui Name="RunInfo" IgnoreGuiInset>
						<RunInfo elaspedTime={elapsedTime} towerInfo={currentTower as never} />
					</screengui>
					<screengui Name="MenuButton" IgnoreGuiInset>
						<MenuButton />
					</screengui>
				</>
			);
		}, Players.LocalPlayer.WaitForChild("PlayerGui"));
	}
}
