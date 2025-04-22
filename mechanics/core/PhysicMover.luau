--!strict

-- WELCOME TO HELL: COMMENT CORE MECHANIC WARNING

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local utils = require(ReplicatedStorage:WaitForChild("MechanicUtils"))

type PhysicMoverInstance = Instance & {
	Positions: Instance,
	Mover: BasePart & {
		AlignPosition: AlignPosition,
		AlignOrientation: AlignOrientation,
	},
}

local function init(wth: utils.WTH)
	-- local PhysicMover = wth:tag(
	-- 	"PhysicMover",
	-- 	utils.t.children({
	-- 		Positions = utils.t.Instance,
	-- 		Mover = utils.t.instanceIsA("BasePart", {
	-- 			AlignPosition = utils.t.instanceOf("AlignPosition"),
	-- 			AlignOrientation = utils.t.instanceOf("AlignOrientation"),
	-- 		}),
	-- 	}) :: utils.check<PhysicMoverInstance>
	-- )

	-- local PhysicMoverPosition = wth:tag("PhysicMoverPosition", utils.t.instanceIsA("BasePart") :: utils.check<BasePart>)

	-- local PhysicMoverId = utils.attribute("PhysicMoverId", utils.t.string)

	-- local SetPositionsInvisible = utils.attribute("SetPositionsInvisible", utils.t.boolean, true)
	-- local Interval = utils.attribute("Interval", utils.t.numberPositive, 1)

	-- local lastReset: utils.Map<string, number> = {}

	-- -- TODO: perf this
	-- local function getPositionsWithId(id: string)
	-- 	local possiblePositions = {}
	-- 	for _, pos in PhysicMoverPosition:instances() do
	-- 		if PhysicMoverId(pos) == id then
	-- 			table.insert(possiblePositions, pos)
	-- 		end
	-- 	end
	-- 	local sortedPositions = {}
	-- 	for index = 1, #possiblePositions do
	-- 		local got = false
	-- 		for _, pos in possiblePositions do
	-- 			if pos.Name == tostring(index) then
	-- 				table.insert(sortedPositions, pos)
	-- 				got = true
	-- 				break
	-- 			end
	-- 			if not got then
	-- 				error("not sequential")
	-- 			end
	-- 		end
	-- 	end
	-- 	return sortedPositions
	-- end

	-- PhysicMover:onLoaded(function(trove, mover)
	-- 	local id = PhysicMoverId(mover)
	-- 	if not id then
	-- 		return
	-- 	end

	-- 	local setPositionsInvisible = SetPositionsInvisible(mover)
	-- end)

	-- wth:onPhysics(function(trove)
	-- 	local now = os.clock()
	-- 	for _, mover in PhysicMover:instances() do
	-- 		local id = PhysicMoverId(mover)
	-- 		if not id then
	-- 			continue
	-- 		end

	-- 		local positions = getPositionsWithId(id)
	-- 		local interval = Interval(mover)
	-- 		local moverLastReset = lastReset[id] or now
	-- 		local intervals = (now - moverLastReset) % interval

	-- 		print(intervals)
	-- 	end
	-- end)
end

return init
