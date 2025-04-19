export type WTH = {
	useTag: (self: WTH, tag: string, check: () -> ()) -> (),
}
