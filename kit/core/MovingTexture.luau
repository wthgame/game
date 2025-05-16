--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local std = require(ReplicatedStorage:WaitForChild("KitStd"))
local prelude = std.prelude

local HorizontalOffset = prelude.attribute("HorizontalSpeed", prelude.t.number)
local VerticalOffset = prelude.attribute("VerticalSpeed", prelude.t.number)
local HorizontalSpeed = prelude.attribute("HorizontalSpeed", prelude.t.number, 0)
local VerticalSpeed = prelude.attribute("VerticalSpeed", prelude.t.number, 0)
local HorizontalLoop = prelude.attribute("HorizontalLoop", prelude.isBoolean, true)
local VerticalLoop = prelude.attribute("VerticalLoop", prelude.isBoolean, true)
local Synchronized = prelude.attribute("Synchronized", prelude.isBoolean, true)

local self = {} :: std.KitScript
self.type = "KitScript"

function self:run(kit: std.Kit)
	local MovingTexture = kit:tag("MovingTexture", prelude.t.instanceIsA("Texture") :: std.check<Texture>)

	MovingTexture:onLoaded(function(_, texture)
		if not HorizontalOffset(texture) then
			texture:SetAttribute(HorizontalOffset.name, texture.OffsetStudsU)
		end
		if not VerticalOffset(texture) then
			texture:SetAttribute(VerticalOffset.name, texture.OffsetStudsV)
		end
	end)

	kit:onRender(function(_, dt)
		local loadedLifetime = kit:loadedLifetime()
		for _, toMove in MovingTexture:instances() do
			if not prelude.Active(toMove) then
				continue
			end

			local xSpeed = HorizontalSpeed(toMove)
			local ySpeed = VerticalSpeed(toMove)

			if xSpeed ~= 0 then
				local offset = HorizontalOffset:assert(toMove) :: number
				local newOffset = if Synchronized(toMove)
					-- FIXME: this is broken when speed < studspertile
					then offset + xSpeed / toMove.StudsPerTileU * loadedLifetime
					else toMove.OffsetStudsU + offset + xSpeed * dt
				toMove.OffsetStudsU = if HorizontalLoop(toMove) then newOffset % toMove.StudsPerTileU else newOffset
			end

			if ySpeed ~= 0 then
				local offset = VerticalOffset:assert(toMove) :: number
				local newOffset = if Synchronized(toMove)
					-- FIXME: this is broken when speed < studspertile
					then offset + ySpeed / toMove.StudsPerTileV * loadedLifetime
					else toMove.OffsetStudsV + offset + ySpeed * dt
				toMove.OffsetStudsV = if VerticalLoop(toMove) then newOffset % toMove.StudsPerTileV else newOffset
			end
		end
	end)
end

return self
