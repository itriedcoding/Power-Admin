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

export type Services = {
	Config: any,
	Permissions: any,
	RateLimiter: any,
	AuditLog: any,
	Networking: any,
	Scheduler: any,
	Utils: any,
	Commands: any,
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
}

function Init.GetServices(): Services
	return services
end

return Init

