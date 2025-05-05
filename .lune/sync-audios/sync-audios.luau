-- local fs = require("@lune/fs")
-- local process = require("@lune/process")
-- local regex = require("@lune/regex")
-- local stdio = require("@lune/stdio")

-- export type AudioSyncMode = "Local" | "Upload" | "DryRun"

-- type AudioFile = {
-- 	type: "file",
-- 	path: string,
-- 	hash: string,
-- }

-- type AudioSubDir = {
-- 	type: "subdir",
-- 	path: string,
-- 	contents: AudioDir,
-- }

-- type AudioDirContent = AudioFile | AudioSubDir

-- type AudioDir = { AudioDirContent }

-- local SUPPORTED_AUDIO_EXTENSIONS = regex.new("^.*.(mp3|wav|ogg)$")
-- local INDENT = "\t"

-- local delimiter = if process.os == "windows" then "\\" else "/"
-- local audioDirectory = `{process.cwd}assets{delimiter}audios{delimiter}`

-- local function sortAudioDirContent(lhs: AudioDirContent, rhs: AudioDirContent)
-- 	return if lhs.type == "file" and rhs.type ~= "file"
-- 		then true
-- 		elseif rhs.type == "file" then false
-- 		else lhs.path < rhs.path
-- end

-- local function collectAudios(collectFromDir: string): (AudioDir, number)
-- 	local count = 0
-- 	local dir: AudioDir = {}
-- 	for _, file in fs.readDir(collectFromDir) do
-- 		local path = collectFromDir .. file
-- 		if fs.isFile(path) and SUPPORTED_AUDIO_EXTENSIONS:isMatch(path) then
-- 			local result = process.exec("sha1sum", { path })
-- 			if not result.ok then
-- 				print("Failed to get hash of audio file", path)
-- 				print(result.stdout)
-- 				print(result.stderr)
-- 				return process.exit(1)
-- 			end
-- 			count += 1
-- 			table.insert(
-- 				dir,
-- 				{
-- 					type = "file",
-- 					path = path,
-- 					hash = result.stdout:match("%w+"),
-- 				} :: AudioFile
-- 			)
-- 		elseif fs.isDir(path) then
-- 			local contents, subcount = collectAudios(path .. delimiter)
-- 			count += subcount
-- 			table.insert(
-- 				dir,
-- 				{
-- 					type = "subdir",
-- 					path = path,
-- 					contents = contents,
-- 				} :: AudioSubDir
-- 			)
-- 		end
-- 	end
-- 	table.sort(dir, sortAudioDirContent)
-- 	return dir, count
-- end

-- local function createColorFunction(color: stdio.Color)
-- 	return function(str: string)
-- 		return `{stdio.color(color)}{str}{stdio.color("reset")}`
-- 	end
-- end

-- local function createStyleFunction(style: stdio.Style)
-- 	return function(str: string)
-- 		return `{stdio.style(style)}{str}{stdio.style("reset")}`
-- 	end
-- end

-- local cyan = createColorFunction("cyan")
-- local yellow = createColorFunction("yellow")
-- local bold = createStyleFunction("bold")
-- local dim = createStyleFunction("dim")

-- local function syncAudiosPretty(
-- 	audios: { AudioDirContent },
-- 	sync: (file: AudioFile, indent: number) -> (),
-- 	count: number?,
-- 	indent: number?
-- )
-- 	if count then
-- 		print(bold(`Syncing {count} audio files`))
-- 	end
-- 	local indent = indent or 0
-- 	for _, content in audios do
-- 		if content.type == "file" then
-- 			local filename = content.path:match("[^/]*.%w$")
-- 			print(`{INDENT:rep(indent)}{cyan("Syncing")} {filename} {dim("(" .. content.path .. ")")}`)

-- 			continue
-- 		end
-- 		local dirs = content.path:split(delimiter)
-- 		local dirname = dirs[#dirs]
-- 		print(dim(`{INDENT:rep(indent)}Syncing {dirname}`), `{dim("(" .. content.path .. ")")}`)
-- 		syncAudiosPretty(content.contents, sync, nil, indent + 1)
-- 	end
-- end

-- local contents, count = collectAudios(audioDirectory)
-- syncAudiosPretty(contents, function() end, count)
