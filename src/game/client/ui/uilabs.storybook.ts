import { ReplicatedStorage } from "@rbxts/services";

export = {
	name: "Welcome to Hell",
	storyRoots: [ReplicatedStorage.WaitForChild("WTHClientCore"), ReplicatedStorage.WaitForChild("WTHClientGame")],
};
