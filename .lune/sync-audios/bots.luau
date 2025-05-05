local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

export type Bot = {
	id: number,
	quota: number,
	key: string,
}

local delimiter = if process.os == "windows" then "\\" else "/"

return serde.decode(
		"toml",
		fs.readFile(`{process.cwd}{delimiter}.lune{delimiter}sync-audios{delimiter}bots.toml`)
	).bots :: { Bot }
