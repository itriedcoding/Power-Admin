--!strict
local Init = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local root = script.Parent
local Config = require(root:WaitForChild("Config"))
local Permissions = require(root:WaitForChild("Permissions"))
local RateLimiter = require(root:WaitForChild("RateLimiter"))
local AuditLog = require(root:WaitForChild("AuditLog"))
local Networking = require(root:WaitForChild("Networking"))
local Scheduler = require(root:WaitForChild("Scheduler"))
local Utils = require(root:WaitForChild("Utils"))
local Commands = require(root:WaitForChild("Commands"))
local Bans = require(root:WaitForChild("Bans"))
local RolesStore = require(root:WaitForChild("RolesStore"))
local GroupAdapter = require(root:WaitForChild("GroupAdapter"))
local CommandRegistry = require(root:WaitForChild("CommandRegistry"))
local Targeting = require(root:WaitForChild("Targeting"))
local Warnings = require(root:WaitForChild("Warnings"))
local Notes = require(root:WaitForChild("Notes"))
local Whitelist = require(root:WaitForChild("Whitelist"))
local ServerState = require(root:WaitForChild("ServerState"))

export type Services = {
	Config: any,
	Permissions: any,
	RateLimiter: any,
	AuditLog: any,
	Networking: any,
	Scheduler: any,
	Utils: any,
	Commands: any,
    Bans: any,
    RolesStore: any,
    GroupAdapter: any,
    CommandRegistry: any,
    Targeting: any,
    Warnings: any,
    Notes: any,
    Whitelist: any,
    ServerState: any,
}

local services: Services = {
	Config = Config,
	Permissions = Permissions,
	RateLimiter = RateLimiter,
	AuditLog = AuditLog,
	Networking = Networking,
	Scheduler = Scheduler,
	Utils = Utils,
	Commands = Commands,
    Bans = Bans,
    RolesStore = RolesStore,
    GroupAdapter = GroupAdapter,
    CommandRegistry = CommandRegistry,
    Targeting = Targeting,
    Warnings = Warnings,
    Notes = Notes,
    Whitelist = Whitelist,
    ServerState = ServerState,
}

function Init.GetServices(): Services
	return services
end

return Init