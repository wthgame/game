--!strict

local t = require("./packages/t")
local trove = require("./packages/trove")

export type Set<T> = { [T]: true }

-- ew... metatables...
export type InstanceAttribute<T> = typeof(setmetatable(
	{} :: {
		name: string,
		check: t.check<T>?,
		defaultValue: T?,
		get: (self: InstanceAttribute<T>, instance: Instance) -> T,
		assert: (self: InstanceAttribute<T>, instance: Instance) -> typeof(assert((nil :: any) :: T, "Luau")),
	},
	{} :: {
		__tostring: (self: InstanceAttribute<T>) -> string,
		__call: (self: InstanceAttribute<T>, instance: Instance) -> T,
	}
))

export type InstanceTag<T, Self> = Self & {
	get: (self: InstanceTag<T, Self>) -> { T },
	added: (self: InstanceTag<T, Self>, trove: trove.Trove, instance: T) -> (),
	activated: (self: InstanceTag<T, Self>, trove: trove.Trove, instance: T) -> (),
}

local prelude = {
	createAttribute = function<T>(name: string, attributeCheck: t.check<T>): InstanceAttribute<T>
		return nil :: any
	end,
	createTag = function<T, Self>(collectionServiceTag: string, instanceCheck: t.check<T>, self: Self?): InstanceTag<T, Self>
		return nil :: any
	end,
	getMaybeHumanoid = function(): Humanoid
		return nil :: any
	end,
	isBasePart = t.instanceIsA("BasePart") :: t.check<BasePart>,
	isPositiveNumber = t.numberMin(0),
}

local Tripper = prelude.createTag("Tripper", prelude.isBasePart, {
	debounced = {},
	cooldown = prelude.createAttribute("Cooldown", prelude.isPositiveNumber),

	trip = function(self: Self)
		if not self.debounced[self] then
			local humanoid = prelude.getMaybeHumanoid() :: Humanoid
			humanoid.Sit = true
			self.debounced[self] = true
			task.delay(self.cooldown(self), function(self)
				self.debounced[self] = nil
			end, self)
		end
	end,
})

type Self = typeof(Tripper)

local debounced: Set<typeof(Tripper)> = {}

function Tripper:added(trove, trip)
	if not debounced[self] then
		local humanoid = prelude.getMaybeHumanoid() :: Humanoid
		humanoid.Sit = true
		debounced[self] = true
		task.delay(self.cooldown(trip), function()
			debounced[self] = nil
		end)
	end
end
