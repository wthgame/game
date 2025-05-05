local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

export type LockEntry = {
	uploader: number,
	id: number,
	hash: string,
}

local delimiter = if process.os == "windows" then "\\" else "/"
local path = `{process.cwd}{delimiter}.lune{delimiter}sync-audios{delimiter}.lock`

local function get(): { LockEntry }
	return serde.decode("toml", fs.readFile(path)).entries
end

local function add(entry: LockEntry)
	local now = serde.decode("toml", fs.readFile(path))
	table.insert(now.entries, entry)
	fs.writeFile(path, serde.encode("toml", now))
end

return {
	get = get,
	add = add,
}
