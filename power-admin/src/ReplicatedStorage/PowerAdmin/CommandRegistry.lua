--!strict
local CommandRegistry = {}

local registry: { [string]: { desc: string, perm: string?, args: { string }?, category: string? } } = {
	help = { desc = "Show help for commands", args = {"[name?]"}, category = "Core" },
	cmds = { desc = "List available commands", category = "Core" },
	grant = { desc = "Grant role to player(s)", perm = "players.grant", args = {"<player>", "<role>"}, category = "Roles" },
	revoke = { desc = "Revoke role (reset)", perm = "players.revoke", args = {"<player>"}, category = "Roles" },
	kick = { desc = "Kick player(s)", perm = "players.kick", args = {"<player>", "[reason]"}, category = "Moderation" },
	ban = { desc = "Permanent ban", perm = "players.ban", args = {"<player>", "[reason]"}, category = "Moderation" },
	unban = { desc = "Remove ban", perm = "players.unban", args = {"<userId>"}, category = "Moderation" },
	tban = { desc = "Temp ban with duration", perm = "players.tban", args = {"<player>", "<duration>", "[reason]"}, category = "Moderation" },
	mute = { desc = "Mute player(s)", perm = "players.mute", args = {"<player>", "[duration]"}, category = "Chat" },
	unmute = { desc = "Unmute player(s)", perm = "players.mute", args = {"<player>"}, category = "Chat" },
	announce = { desc = "Announce to server", perm = "server.announce", args = {"<message>"}, category = "Server" },
	pm = { desc = "Private message", perm = "server.pm", args = {"<player>", "<message>"}, category = "Server" },
	shutdown = { desc = "Shutdown server", perm = "server.shutdown", category = "Server" },
	stats = { desc = "Show server stats", perm = "server.stats", category = "Server" },
	tp = { desc = "Teleport players to a target", perm = "players.teleport", args = {"<player>", "<toTarget>"}, category = "Player" },
	bring = { desc = "Bring players to you", perm = "players.teleport", args = {"<player>"}, category = "Player" },
	freeze = { desc = "Freeze players", perm = "players.freeze", args = {"<player>"}, category = "Player" },
	thaw = { desc = "Unfreeze players", perm = "players.thaw", args = {"<player>"}, category = "Player" },
	speed = { desc = "Set WalkSpeed", args = {"<player|me>", "<number>"}, category = "Player" },
	health = { desc = "Set Health", args = {"<player|me>", "<number>"}, category = "Player" },
	alias = { desc = "Define alias", perm = "players.grant", args = {"<name>", "<command>"}, category = "Core" },
	macro = { desc = "Define macro", perm = "players.grant", args = {"<name>", "<cmd;cmd;...>"}, category = "Core" },
	["macro-run"] = { desc = "Run macro", args = {"<name>"}, category = "Core" },
    warn = { desc = "Warn a player", perm = "warnings.add", args = {"<player>", "[reason]"}, category = "Moderation" },
    warns = { desc = "List warnings", perm = "warnings.view", args = {"<player>"}, category = "Moderation" },
    unwarn = { desc = "Remove a warning", perm = "warnings.add", args = {"<player>"}, category = "Moderation" },
    note = { desc = "Add a staff note", perm = "notes.write", args = {"<player>", "<text>"}, category = "Moderation" },
    notes = { desc = "List notes", perm = "notes.read", args = {"<player>"}, category = "Moderation" },
    wlist = { desc = "Whitelist ops", perm = "whitelist.manage", args = {"<add|remove|list>", "[userId]"}, category = "Access" },
    lock = { desc = "Lock server (whitelist only)", perm = "server.lock", category = "Access" },
    unlock = { desc = "Unlock server", perm = "server.lock", category = "Access" },
}

function CommandRegistry.get()
	return registry
end

return CommandRegistry

