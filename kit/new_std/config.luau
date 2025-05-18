local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local attributes = require("./attributes")
local t = require("./packages/t")

local isStudio = RunService:IsStudio()

local Debug = attributes.attribute("Debug", t.boolean, isStudio)
local Typecheck = attributes.attribute("Typecheck", t.boolean, isStudio)

--- @class KitStdConfig
--- Global and immutable configuration for the Kit.
local config = {}

--- @prop debug boolean
--- Controls whether debug mode is enabled for the Kit.
---
--- In debug, additional logging and checks may be performed, which can
--- help tower building. Enabling debug mode will impact performance.
---
--- When debug is enabled, the maximum logger level is set to verbose.
--- Otherwise, it is set to warnings and errors.
---
--- Defaults to the "Debug" attribute on the Workspace, or otherwise whether the
--- game is running in Roblox Studio.
---
--- Reexposed as `_G.WTH_DEBUG`.
config.debug = Debug(Workspace)

--- @prop typecheck boolean
--- @within KitStdConfig
---
--- Determines if the standard library should perform runtime type validation,
--- helping to catch type errors while authoring kit scripts and kit objects.
--- However, this adds a performance overhead.
---
--- Defaults to the "Typecheck" attribute on the Workspace, or otherwise whether
--- the game is running in Roblox Studio.
---
--- Reexposed as `_G.WTH_TYPECHECK`.
config.typecheck = Typecheck(Workspace)

-- We expose config variables through _G to take advantage of future darklua
-- generation.
_G.WTH_DEBUG = config.debug
_G.WTH_TYPECHECK = config.typecheck

return table.freeze(config)
