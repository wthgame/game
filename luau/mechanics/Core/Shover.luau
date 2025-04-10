--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type ShoverAttributes = {
	Distance: number,
	InDelay: number,
	InSpeed: number,
	OutDelay: number,
	OutSpeed: number,
}

type ShoverInstance = Instance & {
	Shover: BasePart & {
		Attachment: Attachment,
	},
	Anchor: BasePart & {
		Attachment: Attachment,
		PrismaticConstraint: PrismaticConstraint,
	},
}

local self = {} :: utils.Mechanic<ShoverAttributes, ShoverInstance>
self.type = "Mechanic"
self.name = "Shover"

self.attributes = {
	Distance = utils.t.numberPositive,
	InDelay = utils.t.numberPositive,
	InSpeed = utils.t.numberPositive,
	OutDelay = utils.t.numberPositive,
	OutSpeed = utils.t.numberPositive,
}

self.defaultAttributes = {
	Distance = 5,
	InDelay = 1,
	InSpeed = 20,
	OutDelay = 1,
	OutSpeed = 40,
}

self.instanceCheck = utils.t.children({
	Shover = utils.t.instanceIsA("BasePart", {
		Attachment = utils.t.instanceOf("Attachment"),
	}),
	Anchor = utils.t.instanceIsA("BasePart", {
		Attachment = utils.t.instanceOf("Attachment"),
		PrismaticConstraint = utils.t.instanceOf("PrismaticConstraint"),
	}),
})

-- TODO: make it better
function self:mechanize(ctx)
	local prismaticConstraint = ctx.instance.Anchor.PrismaticConstraint
	prismaticConstraint.UpperLimit = ctx.getAttribute("Distance")

	local isRunning = true
	ctx.trove:add(function()
		isRunning = false
	end)

	while isRunning do
		task.wait(ctx.getAttribute("OutDelay"))

		local outSpeed = ctx.getAttribute("OutSpeed")
		prismaticConstraint.LinearResponsiveness = outSpeed
		prismaticConstraint.Speed = outSpeed
		prismaticConstraint.TargetPosition = ctx.getAttribute("Distance")

		task.wait(ctx.getAttribute("InDelay"))

		local inSpeed = ctx.getAttribute("InSpeed")
		prismaticConstraint.LinearResponsiveness = inSpeed
		prismaticConstraint.Speed = inSpeed
		prismaticConstraint.TargetPosition = 0
	end
end

return self
