import { Controller } from "@flamework/core";
import { Players } from "@rbxts/services";

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

@Controller()
export class CharacterController {
	public isCharacterAlive(): boolean {
		const humanoid = this.getMaybeHumanoid();
		return humanoid !== undefined && humanoid.Health > 0;
	}

	public getMaybeCharacter(): Maybe<Character> {
		return <Maybe<Character>>Players.LocalPlayer.Character;
	}

	public async waitForCharacter(): Promise<Character> {
		return <Character>Players.LocalPlayer.CharacterAdded.Wait()[0];
	}

	public async getCharacter(): Promise<Character> {
		return this.getMaybeCharacter() ?? (await this.waitForCharacter());
	}

	public getMaybeRoot(): Maybe<BasePart> {
		return this.getMaybeCharacter()?.FindFirstChild<BasePart>("HumanoidRootPart");
	}

	public async getRoot(): Promise<BasePart> {
		return (await this.getCharacter()).WaitForChild<BasePart>("HumanoidRootPart");
	}

	public getMaybeHumanoid(): Maybe<Humanoid> {
		return this.getMaybeCharacter()?.FindFirstChild<Humanoid>("Humanoid");
	}

	public async getHumanoid(): Promise<Humanoid> {
		return (await this.getCharacter()).WaitForChild<Humanoid>("Humanoid");
	}
}
