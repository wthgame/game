--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

--- @class MovingTexture
--- @tag KitObject
---
--- Continuously moves a Texture horizontally and vertically, also known as
--- it's UV coordinates.
local self = {} :: std.KitScript
self.implements = { KitScript = true }

--- @prop HorizontalOffset number
--- @within MovingTexture
--- @tag Attribute
---
--- The initial or current horizontal offset, or the U-coordinate, of the
--- texture. Defaults to the Texture's `OffsetStudsU` when loaded.
local HorizontalOffset = prelude.Attribute("HorizontalSpeed", prelude.t.number)

--- @prop VerticalOffset number
--- @within MovingTexture
--- @tag Attribute
---
--- The initial or current vertical offset, or the V-coordinate, of the texture.
--- Defaults to the Texture's `OffsetStudsV` when loaded.
local VerticalOffset = prelude.Attribute("VerticalSpeed", prelude.t.number)

--- @prop HorizontalSpeed number
--- @within MovingTexture
--- @tag Attribute
---
--- The speed, in studs per second, at which the texture moves horizontally
--- along its U-coordinate. A positive value moves it right, a negative value
--- moves it left.
local HorizontalSpeed = prelude.Attribute("HorizontalSpeed", prelude.t.number, 0)

--- @prop VerticalSpeed number
--- @within MovingTexture
--- @tag Attribute
---
--- The speed, in studs per second, at which the texture moves vertically
--- along its V-coordinate. A positive value moves it up, a negative value
--- moves it down.
local VerticalSpeed = prelude.Attribute("VerticalSpeed", prelude.t.number, 0)

--- @prop HorizontalLoop boolean
--- @within MovingTexture
--- @tag Attribute
---
--- If enabled, the MovingTexture will loop back to it's `HorizontalOffset` once
--- it exceeds the `StudsPerTileU` value. May help prevent floating point
--- errors.
local HorizontalLoop = prelude.Attribute("HorizontalLoop", prelude.isBoolean, true)

--- @prop VerticalLoop boolean
--- @within MovingTexture
--- @tag Attribute
---
--- If enabled, the MovingTexture will loop back to it's `VerticalOffset` once
--- it exceeds the `StudsPerTileV` value. May help prevent floating point
--- errors.
local VerticalLoop = prelude.Attribute("VerticalLoop", prelude.isBoolean, true)

--- @prop Synchronized boolean
--- @within MovingTexture
--- @tag Attribute
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
local Synchronized = prelude.Attribute("Synchronized", prelude.isBoolean, true)

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
					then offset + xSpeed / toMove.StudsPerTileU * loadedLifetime
					else toMove.OffsetStudsU + xSpeed * dt
				toMove.OffsetStudsU = if HorizontalLoop(toMove) then newOffset % toMove.StudsPerTileU else newOffset
			end

			if ySpeed ~= 0 then
				local offset = VerticalOffset:assert(toMove) :: number
				local newOffset = if Synchronized(toMove)
					then offset + ySpeed / toMove.StudsPerTileV * loadedLifetime
					else toMove.OffsetStudsV + ySpeed * dt
				toMove.OffsetStudsV = if VerticalLoop(toMove) then newOffset % toMove.StudsPerTileV else newOffset
			end
		end
	end)
end

return self
