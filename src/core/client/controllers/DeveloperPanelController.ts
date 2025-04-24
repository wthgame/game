import { Controller, Modding, OnStart } from "@flamework/core";
import Iris from "@rbxts/iris";
import { UserInputService } from "@rbxts/services";

export interface DeveloperPanelDropdownRenderer {
	renderDeveloperPanelDropdown(): void;
}

@Controller()
export class DeveloperPanelController implements OnStart {
	private isOpen = false;
	private dropdownRenderers = new Array<DeveloperPanelDropdownRenderer>();

	onStart(): void {
		Modding.onListenerAdded<DeveloperPanelDropdownRenderer>((object) => this.dropdownRenderers.push(object));
		Modding.onListenerRemoved<DeveloperPanelDropdownRenderer>((object) =>
			this.dropdownRenderers.remove(this.dropdownRenderers.indexOf(object)),
		);

		this.dropdownRenderers.sort((lhs, rhs) => tostring(lhs) < tostring(rhs));

		Iris.Init();
		Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark);
		Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear);
		Iris.Connect(() => this.render());

		UserInputService.InputBegan.Connect((input, gc) => {
			if (!gc && input.KeyCode === Enum.KeyCode.Comma) this.isOpen = !this.isOpen;
		});
	}

	// @OnInput(new StandardActionBuilder("Comma"))
	// open() {
	// 	this.isOpen = !this.isOpen;
	// }

	render() {
		if (!this.isOpen) return;
		Iris.Window(["Welcome To Hell Developer Panel"]);
		for (const renderer of this.dropdownRenderers) {
			Iris.Tree([tostring(renderer)]);
			renderer.renderDeveloperPanelDropdown();
			Iris.End();
		}
		Iris.End();
	}
}
