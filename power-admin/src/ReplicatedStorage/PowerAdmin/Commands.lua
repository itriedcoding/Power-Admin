--!strict
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Commands = {}

type CommandContext = {
	actor: Player,
	services: any,
	text: string,
	args: { string },
	appendAudit: (entry: any) -> (),
	checkPerm: (perm: string) -> (),
}

local function getCharacter(player: Player): Model?
	return player.Character or player.CharacterAdded:Wait()
end

local function parseArgs(text: string): { string }
	local args = {}
	for token in string.gmatch(text, "[^%s]+") do
		table.insert(args, token)
	end
	return args
end

local function makeContext(actor: Player, services, text: string): CommandContext
	local args = parseArgs(text)
	local function checkPerm(perm: string)
		if not services.Permissions.userHasPermission(actor.UserId, perm) then
			error("Missing permission: " .. perm)
		end
	end
	return {
		actor = actor,
		services = services,
		text = text,
		args = args,
		appendAudit = services.AuditLog.append,
		checkPerm = checkPerm,
	}
end

local registry: { [string]: (ctx: CommandContext) -> (boolean, string?) } = {}

local function register(name: string, fn)
	registry[name] = fn
end

local function findTargets(services, actor: Player, token: string): { Player }
	-- Use server-side resolution (by name, team, etc.)
	local targets: { Player } = {}
	local lower = string.lower(token)
	if lower == "me" then
		targets = { actor }
	elseif lower == "all" then
		targets = Players:GetPlayers()
	elseif lower == "others" then
		for _, p in Players:GetPlayers() do if p ~= actor then table.insert(targets, p) end end
	elseif string.find(lower, "name:") == 1 then
		local name = string.sub(lower, 6)
		for _, p in Players:GetPlayers() do
			if string.find(string.lower(p.Name), name, 1, true) then table.insert(targets, p) end
		end
	elseif string.find(lower, "team:") == 1 then
		local teamName = string.sub(lower, 6)
		for _, p in Players:GetPlayers() do
			if p.Team and string.lower(p.Team.Name) == teamName then table.insert(targets, p) end
		end
	else
		for _, p in Players:GetPlayers() do
			if string.find(string.lower(p.Name), lower, 1, true) then table.insert(targets, p) end
		end
	end
	return targets
end

-- Registration

register("help", function(ctx)
	return true, "Power Admin: ;cmds, ;help <name>"
end)

register("cmds", function(ctx)
	return true, table.concat({ "help", "cmds", "grant", "revoke", "kick", "ban", "unban", "tban", "logs", "tp", "bring", "freeze", "thaw", "speed", "health", "alias", "macro", "macro-run" }, ", ")
end)

register("grant", function(ctx)
	ctx.checkPerm("players.grant")
	local targetToken = ctx.args[2]
	local roleName = ctx.args[3]
	if not targetToken or not roleName then error("Usage: ;grant <player> <role>") end
	local targets = findTargets(ctx.services, ctx.actor, targetToken)
	for _, p in targets do
		ctx.services.Permissions.setRole(p.UserId, roleName)
	end
	return true, "Granted " .. roleName .. " to " .. #targets .. " user(s)."
end)

register("revoke", function(ctx)
	ctx.checkPerm("players.revoke")
	local targetToken = ctx.args[2]
	if not targetToken then error("Usage: ;revoke <player>") end
	local targets = findTargets(ctx.services, ctx.actor, targetToken)
	for _, p in targets do
		ctx.services.Permissions.setRole(p.UserId, ctx.services.Config.DefaultRole)
	end
	return true, "Reverted role for " .. #targets .. " user(s)."
end)

register("kick", function(ctx)
	ctx.checkPerm("players.kick")
	local targetToken = ctx.args[2]
	local reason = ctx.args[3] or "Kicked by staff"
	local targets = findTargets(ctx.services, ctx.actor, targetToken)
	for _, p in targets do
		p:Kick(reason)
	end
	return true, "Kicked " .. #targets .. " user(s)."
end)

register("ban", function(ctx)
	ctx.checkPerm("players.ban")
	local targetToken = ctx.args[2]
	local reason = ctx.args[3] or "Banned"
	local targets = findTargets(ctx.services, ctx.actor, targetToken)
	for _, p in targets do
		ctx.services.Bans.addBan(p.UserId, 0, reason)
		p:Kick("Banned: " .. reason)
	end
	return true, "Banned " .. #targets .. " user(s)."
end)

register("unban", function(ctx)
	ctx.checkPerm("players.unban")
	local idStr = ctx.args[2]
	if not idStr then error("Usage: ;unban <userId>") end
	local id = tonumber(idStr)
	if not id then error("Invalid userId") end
	ctx.services.Bans.removeBan(id)
	return true, "Unbanned " .. idStr
end)

register("tban", function(ctx)
	ctx.checkPerm("players.tban")
	local targetToken = ctx.args[2]
	local durationStr = ctx.args[3]
	if not targetToken or not durationStr then error("Usage: ;tban <player> <duration>") end
	local seconds = ctx.services.Utils.parseDuration(durationStr)
	if not seconds then error("Invalid duration") end
	local reason = ctx.args[4] or "Temp banned"
	local untilTs = os.time() + seconds
	local targets = findTargets(ctx.services, ctx.actor, targetToken)
	for _, p in targets do
		ctx.services.Bans.addBan(p.UserId, untilTs, reason)
		p:Kick("Temp ban (" .. durationStr .. "): " .. reason)
	end
	return true, "Temp banned " .. #targets .. " user(s)"
end)

register("logs", function(ctx)
	ctx.checkPerm("logs.read")
	local recent = ctx.services.AuditLog.getRecent(50)
	return true, "Recent logs: " .. tostring(#recent)
end)

register("tp", function(ctx)
	ctx.checkPerm("players.teleport")
	local a = ctx.args[2]
	local b = ctx.args[3]
	if not a or not b then error("Usage: ;tp <player> <toTarget>") end
	local targetsA = findTargets(ctx.services, ctx.actor, a)
	local targetsB = findTargets(ctx.services, ctx.actor, b)
	if #targetsB == 0 then error("No target to teleport to") end
	local destChar = getCharacter(targetsB[1])
	local hrp = destChar and destChar:FindFirstChild("HumanoidRootPart")
	if not hrp then error("Destination HRP not found") end
	for _, p in targetsA do
		local char = getCharacter(p)
		local part = char and char:FindFirstChild("HumanoidRootPart")
		if part then part.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 3 end
	end
	return true, "Teleported " .. #targetsA .. " player(s)."
end)

register("bring", function(ctx)
	ctx.checkPerm("players.teleport")
	local token = ctx.args[2]
	if not token then error("Usage: ;bring <player>") end
	local targets = findTargets(ctx.services, ctx.actor, token)
	local destChar = getCharacter(ctx.actor)
	local hrp = destChar and destChar:FindFirstChild("HumanoidRootPart")
	if not hrp then error("Your HRP not found") end
	for _, p in targets do
		local char = getCharacter(p)
		local part = char and char:FindFirstChild("HumanoidRootPart")
		if part then part.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 4 end
	end
	return true, "Brought " .. #targets .. " player(s)."
end)

register("freeze", function(ctx)
	ctx.checkPerm("players.freeze")
	local token = ctx.args[2]
	local targets = findTargets(ctx.services, ctx.actor, token)
	for _, p in targets do
		local char = getCharacter(p)
		if char then
			for _, part in char:GetDescendants() do
				if part:IsA("BasePart") then part.Anchored = true end
			end
		end
	end
	return true, "Frozen " .. #targets .. " player(s)."
end)

register("thaw", function(ctx)
	ctx.checkPerm("players.thaw")
	local token = ctx.args[2]
	local targets = findTargets(ctx.services, ctx.actor, token)
	for _, p in targets do
		local char = getCharacter(p)
		if char then
			for _, part in char:GetDescendants() do
				if part:IsA("BasePart") then part.Anchored = false end
			end
		end
	end
	return true, "Thawed " .. #targets .. " player(s)."
end)

register("speed", function(ctx)
	local selfOnly = not ctx.services.Permissions.userHasPermission(ctx.actor.UserId, "players.speed")
	if selfOnly then
		if not ctx.services.Permissions.userHasPermission(ctx.actor.UserId, "self.speed") then error("No permission") end
	end
	local token = ctx.args[2]
	local value = tonumber(ctx.args[3])
	if not token or not value then error("Usage: ;speed <player|me> <number>") end
	local targets = selfOnly and { ctx.actor } or findTargets(ctx.services, ctx.actor, token)
	for _, p in targets do
		local char = getCharacter(p)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = value end
	end
	return true, "Speed set for " .. #targets .. " player(s)."
end)

register("health", function(ctx)
	local selfOnly = not ctx.services.Permissions.userHasPermission(ctx.actor.UserId, "players.health")
	if selfOnly then
		if not ctx.services.Permissions.userHasPermission(ctx.actor.UserId, "self.health") then error("No permission") end
	end
	local token = ctx.args[2]
	local value = tonumber(ctx.args[3])
	if not token or not value then error("Usage: ;health <player|me> <number>") end
	local targets = selfOnly and { ctx.actor } or findTargets(ctx.services, ctx.actor, token)
	for _, p in targets do
		local char = getCharacter(p)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = value end
	end
	return true, "Health set for " .. #targets .. " player(s)."
end)

-- Aliases and Macros (stored in memory per server)
local aliases: { [string]: string } = {}
local macros: { [string]: string } = {}

register("alias", function(ctx)
	ctx.checkPerm("players.grant") -- only staff
	local name = ctx.args[2]
	local expansion = table.concat(ctx.args, " ", 3)
	if not name or expansion == "" then error("Usage: ;alias <name> <command>") end
	aliases[name] = expansion
	return true, "Alias set: " .. name
end)

register("macro", function(ctx)
	ctx.checkPerm("players.grant")
	local name = ctx.args[2]
	local body = table.concat(ctx.args, " ", 3)
	if not name or body == "" then error("Usage: ;macro <name> <cmd;cmd;...>") end
	macros[name] = body
	return true, "Macro saved: " .. name
end)

register("macro-run", function(ctx)
	local name = ctx.args[2]
	if not name then error("Usage: ;macro-run <name>") end
	local body = macros[name]
	if not body then error("Macro not found") end
	return true, body
end)

function Commands.execute(actor: Player, services, rawText: string): (boolean, string)
	local text = string.gsub(rawText, "^;", "")
	local parts = {}
	if aliases[text] then
		text = aliases[text]
	end
	local successOverall = true
	local messages: { string } = {}
	for _, segment in ipairs(services.Utils.splitCommands(text)) do
		local args = {}
		for token in string.gmatch(segment, "[^%s]+") do table.insert(args, token) end
		local name = string.lower(args[1] or "")
		local fn = registry[name]
		if not fn then
			successOverall = false
			table.insert(messages, "Unknown: " .. name)
		else
			local ctx = makeContext(actor, services, segment)
			local ok, resultOrErr = pcall(function()
				return fn(ctx)
			end)
			if ok then
				local cmdOk, msg = resultOrErr :: any
				successOverall = successOverall and (cmdOk ~= false)
				table.insert(messages, msg or "ok")
			else
				successOverall = false
				table.insert(messages, tostring(resultOrErr))
			end
		end
	end
	return successOverall, table.concat(messages, " | ")
end

return Commands

