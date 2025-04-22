import { memoize } from "core/shared/libs/memoize";

// TODO: implement px scaling
export const px = memoize((value: number) => value);
