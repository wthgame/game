import { Controller, OnStart } from "@flamework/core";
import { Players } from "@rbxts/services";
import Vide, { effect, mount, Source, source } from "@rbxts/vide";
import { useAtom } from "@rbxts/vide-charm";
import { useRem } from "core/client/ui/rem";
import { createLogger } from "core/shared/logger";
import { MenuButton } from "../ui/MenuButton";
import { RunInfo } from "../ui/RunInfo";
import { TowerRunController } from "./TowerRunController";

@Controller()
export class MenuController implements OnStart {
	private logger = createLogger("TowerRunController");

	isMenuOpen: Source<boolean> = source(false);

	constructor(private towerRunController: TowerRunController) {}

	onStart(): void {
		mount(() => {
			useRem();
			const elapsedTime = useAtom(this.towerRunController.elapsedTime);
			const currentTower = useAtom(this.towerRunController.currentTower);

			effect(() => {
				this.logger.debug(`Current tower: ${currentTower()}`);
			});

			effect(() => {
				this.logger.debug(`Menu ${this.isMenuOpen() ? "is" : "is not"} open`);
			});

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
