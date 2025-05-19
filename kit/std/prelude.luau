local activation = require("./activation")
local animation = require("./animation")
local assets = require("./assets")
local attributes = require("./attributes")
local audio = require("./audio")
local character = require("./character")
local logger = require("./logger")
local t = require("./packages/t")

--- @class KitStdPrelude
--- Welcome To Hell comes with a variety of things in its utility
--- library. However, if you had to manually import every single thing
--- that you used, it would be very verbose. But importing a lot of
--- things that a script never uses isn’t good either. A balance needs
--- to be struck.
---
--- The prelude is the list of things that most KitScripts will use, and
--- is kept as small as possible.
---
--- ```luau
--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- local std = require(ReplicatedStorage:WaitForChild("KitStd"))
--- local prelude = std.prelude
--- ```
---
--- When Luau table destructuring is implemented, the prelude can be
--- imported as such:
---
--- ```luau
--- local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- local std = require(ReplicatedStorage:WaitForChild("KitStd"))
--- -- waiting on https://github.com/luau-lang/rfcs/pull/95
--- local { .attribute, .isBasePart, .getMaybeRootPart } = std.prelude
--- ```
local prelude = {}
prelude.createLogger = logger.createLogger

prelude.attribute = attributes.attribute
prelude.Activatable = activation.Activatable
prelude.Enabled = activation.Enabled
prelude.onActivated = activation.onActivated

prelude.getHumanoid = character.getHumanoid
prelude.getMaybeHumanoid = character.getMaybeHumanoid
prelude.getHumanoidRootPart = character.getHumanoidRootPart
prelude.getMaybeHumanoidRootPart = character.getMaybeHumanoidRootPart

prelude.t = t
prelude.isBasePart = t.instanceIsA("BasePart") :: t.check<BasePart>
prelude.isPositiveNumber = t.numberMin(0)
prelude.isBoolean = t.boolean
prelude.isString = t.string

prelude.tweenConfigFromAttributes = animation.tweenConfigFromAttributes
prelude.tween = animation.tween
prelude.tweenMaybeInstant = animation.tweenMaybeInstant

prelude.IMAGE_ASSETS = assets.IMAGE_ASSETS
prelude.AUDIO_ASSETS = audio.AUDIO_ASSETS
prelude.inferAndPlaySound = audio.inferAndPlaySound
prelude.playSound = audio.playSound
prelude.playSoundFromGameAssets = audio.playSoundFromGameAssets

return table.freeze(prelude)
