local collectAudios = require("./collect-audios")
local process = require("@lune/process")
local regex = require("@lune/regex")
local stdio = require("@lune/stdio")

local SUPPORTED_AUDIO_EXTENSIONS = regex.new("^.*.(mp3|wav|ogg)$")
local INDENT = "\t"

local delimiter = if process.os == "windows" then "\\" else "/"
local audioDirectory = `{process.cwd}assets{delimiter}audios{delimiter}`

local function sortAudioDirContent(lhs: collectAudios.AudioDirContent, rhs: collectAudios.AudioDirContent)
	return if lhs.type == "file" and rhs.type ~= "file"
		then true
		elseif rhs.type == "file" then false
		else lhs.path < rhs.path
end

local function createColorFunction(color: stdio.Color)
	return function(str: string)
		return `{stdio.color(color)}{str}{stdio.color("reset")}`
	end
end

local function createStyleFunction(style: stdio.Style)
	return function(str: string)
		return `{stdio.style(style)}{str}{stdio.style("reset")}`
	end
end

local cyan = createColorFunction("cyan")
local yellow = createColorFunction("yellow")
local bold = createStyleFunction("bold")
local dim = createStyleFunction("dim")

local function syncAudiosPretty(
	audios: { collectAudios.AudioDirContent },
	sync: (file: collectAudios.AudioFile, indent: number) -> (),
	count: number?,
	indent: number?
)
	if count then
		print(bold(`Syncing {count} audio files`))
	end
	local indent = indent or 0
	for _, content in audios do
		if content.type == "file" then
			local filename = content.path:match("[^/]*.%w$")
			print(`{INDENT:rep(indent)}{cyan("Syncing")} {filename} {dim("(" .. content.path .. ")")}`)

			continue
		end
		local dirs = content.path:split(delimiter)
		local dirname = dirs[#dirs]
		print(dim(`{INDENT:rep(indent)}Syncing {dirname}`), `{dim("(" .. content.path .. ")")}`)
		syncAudiosPretty(content.contents, sync, nil, indent + 1)
	end
end

local mode = stdio.prompt("select", "Select sync mode:", { "Sync locally", "Upload to Roblox", "Dry run" })
local syncCallback
if mode == 1 then
	syncCallback = require("./sync-modes/sync-locally")
elseif mode == 2 then
	syncCallback = require("./sync-modes/upload-to-roblox")
elseif mode == 3 then
	syncCallback = require("./sync-modes/dry-run")
end

local contents, count = collectAudios(audioDirectory, `assets{delimiter}audio{delimiter}`)
syncAudiosPretty(contents, syncCallback, count)
