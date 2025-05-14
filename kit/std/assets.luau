--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Sift = require("./packages/sift")
local assets = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHSharedCore"):WaitForChild("assets"))

return {
	--[=[
        @prop ASSETS typeof(assets)
        @within KitStd

        Image assets used by Welcome To Hell.
    ]=]
	IMAGE_ASSETS = Sift.Dictionary.freezeDeep(Sift.Dictionary.copyDeep(assets)) :: typeof(assets),
}
