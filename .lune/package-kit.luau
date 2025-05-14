local comments = require("./lib/comments")
local remodel = require("./remodel")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local Instance = roblox.Instance

local KIT_DEVELOPMENT_PLACE_ID = 113552277431105

local game: remodel.LuneDataModel
do
	if remodel.isFile("./kit.rbxl") then
		local shouldRedownload = stdio.prompt("confirm", "Do you want to redownload the kit from Roblox?")
		if not shouldRedownload then
			game = remodel.readPlaceFile("./kit.rbxl")
		end
	end

	if not game then
		print("Downloading kit...")
		game = remodel.readPlaceAsset(KIT_DEVELOPMENT_PLACE_ID)
		remodel.writePlaceFile(`./kit.rbxl`, game :: any)
	end
end
local kit = assert(game:GetService("Workspace"):FindFirstChild("Kit"), "Cannot find Kit instance")

do
	print("Replacing comments...")
	for _, script in game:GetDescendants() do
		if not script:IsA("LuaSourceContainer") then
			continue
		end
		local source = (script :: any).Source :: string
		for replace, replaceWith in pairs(comments) do
			source = source:gsub(replace, replaceWith)
		end
		(script :: any).Source = source
	end
end

remodel.createDirAll("./dist/")
remodel.writePlaceFile("./dist/kit-presetup.rbxl", game)

do
	print("Creating Ungroups...")

	local ungroupServices = {
		game:GetService("ServerScriptService"),
		game:GetService("ReplicatedStorage"),
		game:GetService("StarterPack"),
	}

	for _, service in ungroupServices do
		local group = Instance.new("Model")
		group.Name = `Ungroup Me In {service.Name}`

		for _, child in service:GetChildren() do
			child.Parent = group
		end

		group.Parent = kit
	end
end

remodel.writeModelFile("./dist/kit-standalone.rbxm", kit)
