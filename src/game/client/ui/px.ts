import { memoize } from "game/shared/libs/memoize";

// TODO: implement px scaling
export const px = memoize((value: number) => value);
