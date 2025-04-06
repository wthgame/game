type Maybe<T> = T | nil
type Typechecker = (value: unknown) -> (boolean, string?)

type function ShallowPartial(tbl)
    assert(tbl:is("table"), "expected table")

    local newTbl = types.newtable()

    for key in tbl:properties() do
        local read, write = tbl:readproperty(key), tbl:writeproperty(key)
        if read then
            newTbl:setreadproperty(key, types.unionof(read, types.singleton(nil)))
        end
        if write then
            newTbl:setwriteproperty(key, types.unionof(read, types.singleton(nil)))
        end
    end

    local index = tbl:indexer()
    if index then
    local readIndexer, writeIndexer = tbl:readindexer(), tbl:writeindexer()
        if readIndexer then
            newTbl:setreadindexer(index, types.unionof(readIndexer, types.singleton(nil)))
        end
        if writeIndexer then
            newTbl:setreadindexer(index, types.unionof(writeIndexer, types.singleton(nil)))
        end
    end

    return newTbl
end

export type Task =
    | Instance
    | RBXScriptConnection
    | thread
    | () -> ()
    | { [unknown]: unknown, destroy: (self: unknown) -> () }
    | { [unknown]: unknown, Destroy: (self: unknown) -> () }
    | { [unknown]: unknown, disconnect: (self: unknown) -> () }
    | { [unknown]: unknown, Disconnect: (self: unknown) -> () }

export type Scope<Methods> = { Task } & Methods

export type MechanicDescription<A, I> = {
    type: "MechanicDescription",
    name: string,
    attributes: { [keyof<A>]: Typechecker },
    defaultAttributes: A,
    instanceCheck: Typechecker,
    mechanize: (self: MechanicDescription<A, I>, scope: MechanizeScope<A, I>) -> ()
}

export type MechanizeScope<A, I> = {
    id: number,
	instance: I,
	mechanicsFolder: Instance,
	getAttribute: <T>(self: MechanizeScope<A, I>, attribute: T & keyof<A>) -> index<A, T>,
	insertTasks: <Tasks...>(self: MechanizeScope<A, I>, Tasks...) -> Tasks...
}

export type TouchConfig = {
    passLocalPlayerCharacters: boolean?,
    passAllPlayerCharacters: boolean?,
}

return nil
