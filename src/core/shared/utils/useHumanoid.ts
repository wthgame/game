import { useCharacter } from "./useCharacter";

export function useHumanoid(): () => Maybe<Humanoid> {
	const character = useCharacter();
	return () => character()?.Humanoid;
}
