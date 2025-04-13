--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Sift = require("./packages/sift")
local assets = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHShared"):WaitForChild("assets"))

return Sift.Dictionary.freezeDeep(Sift.Dictionary.copyDeep(assets)) :: typeof(assets)
