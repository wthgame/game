--!strict

-- WELCOME TO HELL: COMMENT CORE SCRIPT WARNING

local logger = require(game:GetService("ReplicatedStorage"):WaitForChild("WTHSharedCore"):WaitForChild("logger"))

export type Logger = logger.Logger
export type LoggerMessage = logger.LoggerMessage

return logger
