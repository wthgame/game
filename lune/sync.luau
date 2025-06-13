local process = require("@lune/process")
local stdio = require("@lune/stdio")
local task = require("@lune/task")

local TARGET_LABELS = { "Game (Welcome To Hell)", "Kit (Welcome To Hell Kit Development)" }
local TARGET_GAME_NAMES = { "Welcome To Hell", "Welcome To Hell Kit Development" }
local TARGET_TS_CONFIG = { "game.tsconfig.json", "kit.tsconfig.json" }
local TARGET_BLINK = { "game.blink", "kit.blink" }
local TARGET_PROJECT = { "game.project.json", "kit.project.json" }

local selected = stdio.prompt("select", "Which target are you syncing to?", TARGET_LABELS)

local gameName = TARGET_GAME_NAMES[selected]
local tsConfig = TARGET_TS_CONFIG[selected]
local blink = TARGET_BLINK[selected]
local project = TARGET_PROJECT[selected]

print()
stdio.write(stdio.style("dim"))

print("Compiling rbxts")
local rbxtsProcess = process.create("bunx", { "rbxtsc", "--watch", "--project", tsConfig, "--rojo", project })

print("Compiling core.blink")
local coreBlinkProcess = process.create("blink", { "core.blink", "--watch" })

print("Compiling", blink)
local targetBlinkProcess = process.create("blink", { blink, "--watch" })

print("Generating sourcemap")
local sourcemapProcess = process.create("rojo", {
	"sourcemap",
	"-o",
	"sourcemap.json",
	"--watch",
	"--include-non-scripts",
	project,
})

print("Serving Rojo")
local rojoProcess = process.create("rojo", { "serve", project })

print()
stdio.write(stdio.style("reset"))

stdio.write(stdio.style("bold"))
print("Syncing Welcome To Hell to", gameName)
print(`Open Roblox Studio > Group Experiences > Select 'Team Fireworks' > '{gameName}'`)
print("Then, Plugins > Rojo > Connect > Accept sync if necessary")
stdio.write(stdio.style("reset"))

local function checkChildProcess(child: process.ChildProcess, name: string): boolean
	local status = child:status()
	if not status.ok then
		print(name, "failed with code", status.code)
	end
	return status.ok
end

while task.wait() do
	if
		checkChildProcess(rbxtsProcess, "rbxts")
		and checkChildProcess(coreBlinkProcess, "Blink")
		and checkChildProcess(targetBlinkProcess, "Blink")
		and checkChildProcess(sourcemapProcess, "Rojo")
		and checkChildProcess(rojoProcess, "Rojo")
	then
		continue
	end

	rbxtsProcess:kill()
	coreBlinkProcess:kill()
	targetBlinkProcess:kill()
	sourcemapProcess:kill()
	rojoProcess:kill()

	break
end
