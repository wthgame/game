import { useCharacter } from "./use-character";

export function useHumanoid(): () => Maybe<Humanoid> {
	const character = useCharacter();
	return () => character()?.Humanoid;
}
