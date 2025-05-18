import { Controller, OnInit } from "@flamework/core";
import { Lazy } from "@rbxts/lazy";
import { Players } from "@rbxts/services";
import { OnPreSimulation } from "core/shared/hook-managers/PhysicHookManager";
import { OnPlayerAdded } from "core/shared/hook-managers/PlayersHookManger";
import { Character, CharacterController } from "../CharacterController";

export interface Hitbox extends Model {
	Arms: BasePart;
	Center: BasePart;
	Root: BasePart;
}

const HITBOX_TEMPLATE = new Lazy(() => script.WaitForChild("Hitbox") as Hitbox);
const LOCAL_CHARACTER_COLLISION_GROUP = "Player";
const OTHER_CHARACTER_COLLISION_GROUP = "OtherPlayers";

const DEFAULT_FPS = 1 / 60;
const TRIGGER_FPS = 1 / 75;
const HUMANOID_STATES = [
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.FallingDown,
];

const localPlayer = Players.LocalPlayer;

function weld(p0: BasePart, p1: BasePart): WeldConstraint {
	const weldConstraint = new Instance("WeldConstraint");
	weldConstraint.Part0 = p0;
	weldConstraint.Part1 = p1;
	weldConstraint.Parent = p0;
	return weldConstraint;
}

@Controller()
export class CollisionController implements OnInit, OnPreSimulation, OnPlayerAdded {
	private dt = 0;
	private humanoidStateChangedConnection?: RBXScriptConnection;

	constructor(private characterController: CharacterController) {}

	private setCharacterCollisionGroup(character: Model, collisionGroup: string) {
		for (const child of character.GetChildren()) if (child.IsA("BasePart")) child.CollisionGroup = collisionGroup;
		character.ChildAdded.Connect((child) => {
			if (child.IsA("BasePart")) child.CollisionGroup = collisionGroup;
		});
	}

	private onOtherCharacterAdded(character: Character) {
		this.setCharacterCollisionGroup(character, OTHER_CHARACTER_COLLISION_GROUP);
	}

	private onLocalCharacterAdded(character: Character) {
		this.setCharacterCollisionGroup(character, LOCAL_CHARACTER_COLLISION_GROUP);

		// FIX: head collision
		character.Head.GetPropertyChangedSignal("CanCollide").Connect(() => (character.Head.CanCollide = true));

		const hitbox = HITBOX_TEMPLATE.getValue().Clone();
		const rootHitbox = hitbox.Root;
		const rootPart = character.HumanoidRootPart;
		hitbox.PivotTo(rootPart.GetPivot());
		weld(rootHitbox, rootPart);
		rootHitbox.Anchored = false;
	}

	private observeHumanoidStateChanged(humanoid: Humanoid): RBXScriptConnection {
		return humanoid.StateChanged.Connect((oldState, newState) => {
			if (newState !== oldState) {
				for (const state of HUMANOID_STATES) {
					if (state !== newState) humanoid.SetStateEnabled(state, false);
				}
				task.wait(DEFAULT_FPS - this.dt);
				for (const state of HUMANOID_STATES) {
					if (state !== newState) humanoid.SetStateEnabled(state, true);
				}
			}
		});
	}

	onInit(): void {
		const template = HITBOX_TEMPLATE.getValue();
		weld(template.Arms, template.Root);
		weld(template.Center, template.Root);
	}

	onPlayerAdded(player: Player): void {
		const character = player.Character;
		const onCharacterAdded =
			player === localPlayer
				? (character: Character) => this.onLocalCharacterAdded(character)
				: (character: Character) => this.onOtherCharacterAdded(character);
		player.CharacterAdded.Connect(onCharacterAdded as (character: Model) => void);
		if (character) onCharacterAdded(character as Character);
	}

	onPreSimulation(dt: number): void {
		debug.profilebegin("CollisionController truss fix");

		const humanoid = this.characterController.getMaybeHumanoid();
		if (humanoid) {
			if (dt < TRIGGER_FPS) {
				this.dt = dt;
				if (!this.humanoidStateChangedConnection) {
					this.humanoidStateChangedConnection = this.observeHumanoidStateChanged(humanoid);
				} else if (dt > TRIGGER_FPS) {
					this.humanoidStateChangedConnection.Disconnect();
					this.humanoidStateChangedConnection = undefined;
				}
			}
		}

		debug.profileend();
	}
}
