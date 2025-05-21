import { OnInit, Service } from "@flamework/core";
import { CollectionService, RunService } from "@rbxts/services";

function destroyTag(tag: string) {
	for (const tagged of CollectionService.GetTagged(tag)) tagged.Destroy();
	CollectionService.GetInstanceAddedSignal(tag).Connect((tagged) => tagged.Destroy());
}

@Service({ loadOrder: -1 })
export class StudioTagService implements OnInit {
	onInit(): void {
		if (RunService.IsRunning()) destroyTag("EditOnly");
		if (!RunService.IsStudio()) destroyTag("StudioOnly");
	}
}
