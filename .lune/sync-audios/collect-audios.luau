local fs = require("@lune/fs")
local process = require("@lune/process")
local regex = require("@lune/regex")

export type AudioFile = {
	type: "file",
	path: string,
	relativePath: string,
	hash: string,
}

export type AudioSubDir = {
	type: "subdir",
	path: string,
	contents: AudioDir,
}

export type AudioDirContent = AudioFile | AudioSubDir

export type AudioDir = { AudioDirContent }

local SUPPORTED_AUDIO_EXTENSIONS = regex.new("^.*.(mp3|wav|ogg)$")

local delimiter = if process.os == "windows" then "\\" else "/"

local function sortAudioDirContent(lhs: AudioDirContent, rhs: AudioDirContent)
	return if lhs.type == "file" and rhs.type ~= "file"
		then true
		elseif rhs.type == "file" then false
		else lhs.path < rhs.path
end

local function collectAudios(collectFromDir: string, relativePath: string): (AudioDir, number)
	local count = 0
	local dir: AudioDir = {}
	for _, file in fs.readDir(collectFromDir) do
		local path = collectFromDir .. file
		if fs.isFile(path) and SUPPORTED_AUDIO_EXTENSIONS:isMatch(path) then
			local result = process.exec("sha1sum", { path })
			if not result.ok then
				print("Failed to get hash of audio file", path)
				print(result.stdout)
				print(result.stderr)
				return process.exit(1)
			end
			count += 1
			table.insert(
				dir,
				{
					type = "file",
					path = path,
					relativePath = relativePath .. file,
					hash = result.stdout:match("%w+"),
				} :: AudioFile
			)
		elseif fs.isDir(path) then
			local contents, subcount = collectAudios(path .. delimiter, relativePath .. delimiter)
			count += subcount
			table.insert(
				dir,
				{
					type = "subdir",
					path = path,
					contents = contents,
				} :: AudioSubDir
			)
		end
	end
	table.sort(dir, sortAudioDirContent)
	return dir, count
end

return collectAudios
