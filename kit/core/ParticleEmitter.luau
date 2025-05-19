--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))

local self = {} :: std.KitScript
self.implements = { KitScript = true }

local function emitParticles(_, emitter: Instance)
	for _, descendant in emitter:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant:Emit(descendant.Rate)
		end
	end
end

function self:run(kit: std.Kit)
	local ParticleEmitter = kit:tag("ParticleEmitter")
	ParticleEmitter:onActivated(emitParticles)
end

return self
