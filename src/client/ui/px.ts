import { memoize } from "shared/libs/memoize";

// TODO: implement px scaling
export const px = memoize((value: number) => value);
