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
local BanStore = DataStoreService:GetDataStore(config.DataStore.BanStore, config.DataStore.Scope)
local bans: { [number]: { untilTs: number, reason: string } } = {}

local function loadBans()
	pcall(function()
		local data = BanStore:GetAsync("banned")
		if type(data) == "table" then bans = data end
	end)
end

local function saveBans()
	pcall(function()
		BanStore:SetAsync("banned", bans)
	end)
end

local function isBanned(userId: number): (boolean, string?)
	local entry = bans[userId]
	if not entry then return false, nil end
	if entry.untilTs == 0 then return true, entry.reason end
	if os.time() < entry.untilTs then return true, entry.reason end
	-- expired
	bans[userId] = nil
	saveBans()
	return false, nil
end

local function addBan(userId: number, untilTs: number, reason: string)
	bans[userId] = { untilTs = untilTs, reason = reason }
	saveBans()
end

local function removeBan(userId: number)
	bans[userId] = nil
	saveBans()
end

-- Wire up services object that commands expect
local roleResolver = Services.Permissions.buildUserRoleResolver(config)
local services = {
	Config = config,
	Permissions = roleResolver,
	RateLimiter = Services.RateLimiter,
	AuditLog = audit,
	Networking = networking,
	Scheduler = Services.Scheduler.create(),
	Utils = Services.Utils,
	Commands = Services.Commands,
	Bans = {
		addBan = addBan,
		removeBan = removeBan,
		isBanned = isBanned,
	},
}

-- Player join/leave
loadBans()

Players.PlayerAdded:Connect(function(player)
	local banned, reason = isBanned(player.UserId)
	if banned then
		player:Kick("Banned: " .. (reason or ""))
		return
	end
	-- default role set lazily when checked
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
		return { ok = true, cmds = { "help", "cmds", "grant", "revoke", "kick", "ban", "unban", "tban", "logs", "tp", "bring", "freeze", "thaw", "speed", "health", "alias", "macro", "macro-run" } }
	end
	return { ok = false, error = "unknown" }
end

-- Expose ModuleScript folder for clarity (Roblox runtime doesn't need this return)
return true

