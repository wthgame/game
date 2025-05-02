--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("KitUtils"))

local self = {} :: utils.KitScript
self.type = "KitScript"

local function emitParticles(_, emitter: Instance)
	for _, descendant in emitter:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(descendant.Rate)
		end
	end
end

function self:run(kit: utils.Kit)
	local ParticleEmitter = kit:tag("ParticleEmitter")
	ParticleEmitter:onActivated(emitParticles)
end

return self
