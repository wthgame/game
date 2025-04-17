type Disconnect = () => void;
export declare function collect<T extends Callback>(
	event: RBXScriptSignal<T>,
): LuaTuple<[IterableFunction<LuaTuple<[unknown, ...Parameters<T>]>>, Disconnect]>;
