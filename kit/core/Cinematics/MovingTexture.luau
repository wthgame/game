--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @class MovingTexture
--- @tag KitObjectTag
---
--- WOW
local self = {} :: std.KitScript
self.implements = { KitScript = true }

local HorizontalOffset = prelude.attribute("HorizontalSpeed", prelude.t.number)
local VerticalOffset = prelude.attribute("VerticalSpeed", prelude.t.number)
local HorizontalSpeed = prelude.attribute("HorizontalSpeed", prelude.t.number, 0)
local VerticalSpeed = prelude.attribute("VerticalSpeed", prelude.t.number, 0)
local HorizontalLoop = prelude.attribute("HorizontalLoop", prelude.isBoolean, true)
local VerticalLoop = prelude.attribute("VerticalLoop", prelude.isBoolean, true)

--- @prop Synchronized boolean
--- @within MovingTexture
---
--- If enabled, MovingTexture will be offsetted based on the kit's loaded
--- lifetime, therefore never desyncing. If not, MovingTexture will increment
--- it's offset every frame.
---
--- Synchronized should be used when MovingTextures are being chained to create
--- one continous patterns, so it doesn't desync.
---
--- Synchronized should not be used when the speed of MovingTextures
--- will change, or else it looks jittery. Disabling Synchronized will allow the
--- MovingTexture to adopt the new texture speed.
local Synchronized = prelude.attribute("Synchronized", prelude.isBoolean, true)

function self:run(kit: std.Kit)
	local MovingTexture = kit:tag("MovingTexture", prelude.t.instanceIsA("Texture") :: std.check<Texture>)

	MovingTexture:onLoaded(function(_, texture)
		local xOffset, yOffset = HorizontalOffset(texture), VerticalOffset(texture)

		if not xOffset then
			texture:SetAttribute(HorizontalOffset.name, texture.OffsetStudsU)
		else
			texture.OffsetStudsU = xOffset
		end

		if not yOffset then
			texture:SetAttribute(VerticalOffset.name, texture.OffsetStudsV)
		else
			texture.OffsetStudsV = yOffset
		end
	end)

	kit:onRender(function(_, dt)
		local loadedLifetime = kit:loadedLifetime()
		for _, toMove in MovingTexture:instances() do
			if not prelude.Enabled(toMove) then
				continue
			end

			local xSpeed = HorizontalSpeed(toMove)
			local ySpeed = VerticalSpeed(toMove)

			if xSpeed ~= 0 then
				local offset = HorizontalOffset:assert(toMove) :: number
				local newOffset = if Synchronized(toMove)
					-- FIXME: this is broken when speed < studspertile
					then offset + xSpeed / toMove.StudsPerTileU * loadedLifetime
					else toMove.OffsetStudsU + xSpeed * dt
				toMove.OffsetStudsU = if HorizontalLoop(toMove) then newOffset % toMove.StudsPerTileU else newOffset
			end

			if ySpeed ~= 0 then
				local offset = VerticalOffset:assert(toMove) :: number
				local newOffset = if Synchronized(toMove)
					-- FIXME: this is broken when speed < studspertile
					then offset + ySpeed / toMove.StudsPerTileV * loadedLifetime
					else toMove.OffsetStudsV + ySpeed * dt
				toMove.OffsetStudsV = if VerticalLoop(toMove) then newOffset % toMove.StudsPerTileV else newOffset
			end
		end
	end)
end

return self
