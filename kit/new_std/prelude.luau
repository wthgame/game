local attributes = require("./attributes")
local logger = require("./logger")
local t = require("./packages/t")
local tags = require("./tags")

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

prelude.observeTag = tags.observeTag

prelude.attribute = attributes.attribute

prelude.t = t
prelude.isBasePart = t.instanceIsA("BasePart") :: t.check<BasePart>
prelude.isPositiveNumber = t.numberMin(0)
prelude.isBoolean = t.boolean
prelude.isString = t.string

return table.freeze(prelude)
