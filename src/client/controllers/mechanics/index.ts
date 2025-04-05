import { Controller, OnInit, OnStart } from "@flamework/core";
import { ReplicatedStorage, Workspace } from "@rbxts/services";

const MECHANIC_TAG_PREFIX = "Mechanic:";

export interface MechanicContext {
	instance: Instance;
}

export interface Mechanic {
	init: (self: unknown) => void;
}

export interface MechanicModule {
	self: Mechanic;
	children: Map<string, MechanicModule>;
}

@Controller()
export class MechanicsController implements OnInit, OnStart {
	private mechanicModules = new Map<string, MechanicModule>();

	onInit(): void {
		task.wait(1);
		const mechanics = ReplicatedStorage.WaitForChild("Mechanics");
		this.requireMechanicModule(mechanics.GetChildren(), this.mechanicModules);
		print("MODULES", this.mechanicModules);
	}

	private requireMechanicModule(children: Instance[], map: Map<string, MechanicModule>) {
		for (const c of children) {
			if (!classIs(c, "ModuleScript")) continue;
			const m = require(c) as never;

			const children = new Map<string, MechanicModule>();
			const module: MechanicModule = { self: m, children };
			this.requireMechanicModule(c.GetChildren(), children);

			map.set(c.Name, module);
		}
	}

	onStart(): void {
		// task.wait(1);
		// const mechanics = Workspace.WaitForChild("Mechanics");
		// for (const m of mechanics.GetDescendants()) {
		// 	const tags = m.GetTags();
		// 	if (tags.size() === 0) continue;
		// 	for (const tag of tags) {
		// 		// if (tag.find(MECHANIC_TAG_PREFIX, 1, true)[0]) continue;
		// 		const modulePath = tag.sub(MECHANIC_TAG_PREFIX.size() + 1).split(".");
		// 		print("PATH", modulePath);
		// 		let currentModuleMap = this.mechanicModules;
		// 		let mechanicModule: Maybe<MechanicModule> = undefined;
		// 		for (const component of modulePath) {
		// 			mechanicModule = currentModuleMap.get(component);
		// 			assert(mechanicModule, `no module named ${component} while resolving ${modulePath.join(".")}`);
		// 			currentModuleMap = mechanicModule!.children;
		// 		}
		// 		print("MODULE", mechanicModule);
		// 		assert(mechanicModule, "no mechanic module found");
		// 		mechanicModule.self.init({
		// 			instance: m,
		// 		});
		// 	}
		// }
	}
}
