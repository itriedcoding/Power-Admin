--!strict
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PowerAdmin = require(ReplicatedStorage:WaitForChild("PowerAdmin"):WaitForChild("Init"))
local Services = PowerAdmin.GetServices()

-- Build stateful singletons per server
local config = Services.Config
local networking = Services.Networking.bootstrap()
local audit = Services.AuditLog.create(config)
local rateLimitCommand = Services.RateLimiter.createUserLimiter(config.RateLimits.CommandExec)
local rateLimitUI = Services.RateLimiter.createUserLimiter(config.RateLimits.UI)

-- Bans subsystem
local bansSvc = Services.Bans.create(config)
local warningsSvc = Services.Warnings.create(config)
local notesSvc = Services.Notes.create(config)
local whitelistSvc = Services.Whitelist.create(config)
local serverState = Services.ServerState.create()

-- Wire up services object that commands expect
local roleResolver = Services.Permissions.buildUserRoleResolver(config)
local rolesStore = Services.RolesStore.create(config, roleResolver)
local services = {
	Config = config,
	Permissions = roleResolver,
	RateLimiter = Services.RateLimiter,
	AuditLog = audit,
	Networking = networking,
	Scheduler = Services.Scheduler.create(),
	Utils = Services.Utils,
	Commands = Services.Commands,
	Bans = bansSvc,
    Warnings = warningsSvc,
    Notes = notesSvc,
    Whitelist = whitelistSvc,
    ServerState = serverState,
}

-- Player join/leave
bins = nil
bansSvc.load()
whitelistSvc.load()

Players.PlayerAdded:Connect(function(player)
	local banned, reason = bansSvc.isBanned(player.UserId)
	if banned then
		player:Kick("Banned: " .. (reason or ""))
		return
	end
	if serverState.isLocked() and not whitelistSvc.isWhitelisted(player.UserId) then
		player:Kick("Server locked. You are not whitelisted.")
		return
	end
	-- Apply group-based auto roles, then load stored role
	pcall(function()
		Services.GroupAdapter.autoAssign(config, roleResolver, player)
	end)
	rolesStore.load(player.UserId)
end)

-- Remote handling
networking.RunCommand.OnServerEvent:Connect(function(player, text: string)
	if not rateLimitCommand(player.UserId) then return end
	local ok, msg = pcall(function()
		local success, response = services.Commands.execute(player, services, text)
		return success, response
	end)
	if ok then
		local success, response = msg :: any
		local entry = {
			timestamp = os.time(),
			actorUserId = player.UserId,
			action = "cmd",
			args = text,
			success = success,
			message = response,
		}
		audit.append(entry)
		networking.LogFeed:FireAllClients(entry)
	end
end)

networking.Query.OnServerInvoke = function(player, query: string, data)
	if not rateLimitUI(player.UserId) then return { ok = false, error = "rate" } end
	if query == "getRecentLogs" then
		return { ok = true, logs = audit.getRecent(100) }
	elseif query == "getMyRole" then
		return { ok = true, role = roleResolver.getRole(player.UserId) }
	elseif query == "listCommands" then
		return { ok = true, cmds = Services.CommandRegistry.get() }
    elseif query == "serverState" then
        return { ok = true, locked = serverState.isLocked() }
	end
	return { ok = false, error = "unknown" }
end

-- Expose ModuleScript folder for clarity (Roblox runtime doesn't need this return)
return true

