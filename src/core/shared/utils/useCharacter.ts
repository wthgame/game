import { LockedSource, lockSource } from "@rbxts/pretty-vide-utils";
import { Players } from "@rbxts/services";
import { cleanup, source } from "@rbxts/vide";

export interface Character extends Model {
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription;
		Animator: Animator;
	};
	HumanoidRootPart: BasePart;
	BodyColors: BodyColors;
	PrimaryPart: BasePart;
	Animate: LocalScript;
	Head: BasePart;
}

export function useCharacter(): LockedSource<Maybe<Character>> {
	const character = source<Maybe<Character>>(Players.LocalPlayer.Character as Character);

	cleanup(Players.LocalPlayer.CharacterAdded.Connect((model) => character(model as Character)));
	cleanup(Players.LocalPlayer.CharacterRemoving.Connect(() => character(undefined)));

	return lockSource(character);
}
