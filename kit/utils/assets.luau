--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local Sift = require("./packages/sift")
local assets = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHSharedCore"):WaitForChild("assets"))

return {
	--[=[
        @prop ASSETS typeof(assets)
        @within KitUtils

        Sound assets used by Welcome To Hell.
    ]=]
	SOUND_ASSETS = Sift.Dictionary.freezeDeep(Sift.Dictionary.copyDeep(assets.sounds)) :: typeof(assets.sounds),
	--[=[
        @prop ASSETS typeof(assets)
        @within KitUtils

        UI assets used by Welcome To Hell.
    ]=]
	UI_ASSETS = Sift.Dictionary.freezeDeep(Sift.Dictionary.copyDeep(assets.sounds)) :: typeof(assets.ui),
}
