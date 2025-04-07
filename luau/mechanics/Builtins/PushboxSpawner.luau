--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type PushboxSpawnerAttributes = {
	DoNotSpawnFirst: boolean,
	SpawnCooldownSeconds: number,
	PassLocalPlayerCharacter: boolean,
}

type PushboxSpawnerInstance = Instance & {
	Pushbox: Instance,
	Button: BasePart,
}

local self = {} :: utils.Mechanic<PushboxSpawnerAttributes, PushboxSpawnerInstance>
self.type = "Mechanic"
self.name = "PushboxSpawner"

self.attributes = {
	DoNotSpawnFirst = utils.t.boolean,
}

self.defaultAttributes = {
	DoNotSpawnFirst = true,
	SpawnCooldownSeconds = 0.5,
	PassLocalPlayerCharacter = true,
}

self.instanceCheck = utils.t.children({
	Pushbox = utils.t.Instance,
	Button = utils.t.instanceIsA("BasePart"),
})

function self:mechanize(ctx)
	local pushbox, button = ctx.instance.Pushbox, ctx.instance.Button
	local currentPushbox: Instance? = nil

	local function spawnPushbox()
		if currentPushbox then
			currentPushbox:Destroy()
		end

		local box = pushbox:Clone()
		box.Parent = button
		currentPushbox = box

		if box:IsA("BasePart") then
			box.Anchored = false
		else
			for _, descendant in box:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = false
				end
			end
		end
	end

	local debounce = false
	ctx:pushTasks(button.Touched:Connect(function(toucher)
		if debounce then
			return
		end

		local touchConfig = {
			passLocalPlayerCharacters = ctx:getAttribute("PassLocalPlayerCharacter"),
		}

		if not utils.checkTouched(toucher, touchConfig) then
			return
		end

		spawnPushbox()

		debounce = true

		task.wait(ctx:getAttribute("SpawnCooldownSeconds"))

		debounce = false
	end))

	pushbox.Parent = nil

	if not ctx:getAttribute("DoNotSpawnFirst") then
		spawnPushbox()
	end
end

return self
