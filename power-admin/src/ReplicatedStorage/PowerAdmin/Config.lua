--!strict
local Config = {}

-- Owners always have highest weight and all permissions
Config.Owners = {
	-- Replace with your UserId(s)
	1234567890,
}

-- Default role assigned to new players
Config.DefaultRole = "Member"

Config.Roles = {
	Owner = {
		Weight = 100,
		Permissions = { "*" },
	},
	Admin = {
		Weight = 80,
		Permissions = {
			"players.kick",
			"players.ban",
			"players.tban",
			"players.unban",
			"players.grant",
			"players.revoke",
			"players.freeze",
			"players.thaw",
			"players.teleport",
			"players.speed",
			"players.health",
			"logs.read",
		},
	},
	Moderator = {
		Weight = 60,
		Permissions = {
			"players.kick",
			"players.tban",
			"players.freeze",
			"players.thaw",
			"players.teleport",
			"players.speed",
			"players.health",
			"logs.read",
		},
	},
	Member = {
		Weight = 10,
		Permissions = {
			"self.speed",
			"self.health",
		},
	},
}

Config.FeatureFlags = {
	UseWebhooks = false,
	StrictTargeting = true,
	ConsoleHotkey = true,
}

Config.Webhook = "" -- Provide a Discord-compatible webhook URL if desired

-- DataStore Keys
Config.DataStore = {
	Scope = "PowerAdminV1",
	BanStore = "Bans",
	AuditStore = "Audits",
}

-- Rate limits per user per minute
Config.RateLimits = {
	CommandExec = 30,
	UI = 120,
}

-- UI
Config.UI = {
	Theme = {
		Background = Color3.fromRGB(18, 18, 18),
		Panel = Color3.fromRGB(28, 28, 28),
		Text = Color3.fromRGB(235, 235, 235),
		Accent = Color3.fromRGB(0, 170, 255),
		Danger = Color3.fromRGB(255, 85, 85),
	},
	HotkeyCode = Enum.KeyCode.Slash,
}

return Config

