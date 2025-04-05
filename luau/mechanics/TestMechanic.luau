local lib = require(game:GetService("ReplicatedStorage").Lib)

return lib.mechanic({
	init = function(self)
		print("INSTANCE", self.instance)
	end,
})
