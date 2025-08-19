--!strict
local Players = game:GetService("Players")

local Utils = {}

function Utils.parseDuration(input: string): number?
	local amount, unit = string.match(string.lower(input), "^(%d+)([smhdw])$")
	if not amount then return nil end
	local n = tonumber(amount)
	local mult = 1
	if unit == "s" then mult = 1 end
	if unit == "m" then mult = 60 end
	if unit == "h" then mult = 3600 end
	if unit == "d" then mult = 86400 end
	if unit == "w" then mult = 604800 end
	return n * mult
end

function Utils.splitCommands(line: string): { string }
	local out = {}
	for part in string.gmatch(line, "[^;]+") do
		local trimmed = string.gsub(part, "^%s*(.-)%s*$", "%1")
		if trimmed ~= "" then
			table.insert(out, trimmed)
		end
	end
	return out
end

function Utils.resolveTargets(token: string, strict: boolean): { Player }
	local list: { Player } = {}
	token = string.lower(token)
	if token == "me" then
		local plr = Players.LocalPlayer
		if plr then table.insert(list, plr) end
		return list
	elseif token == "all" then
		for _, p in Players:GetPlayers() do table.insert(list, p) end
		return list
	elseif token == "others" then
		local lp = Players.LocalPlayer
		for _, p in Players:GetPlayers() do if p ~= lp then table.insert(list, p) end end
		return list
	elseif string.find(token, "team:") == 1 then
		local teamName = string.sub(token, 6)
		for _, p in Players:GetPlayers() do
			if p.Team and string.lower(p.Team.Name) == teamName then
				table.insert(list, p)
			end
		end
		return list
	elseif string.find(token, "name:") == 1 then
		local name = string.sub(token, 6)
		for _, p in Players:GetPlayers() do
			if string.find(string.lower(p.Name), name, 1, true) then
				table.insert(list, p)
			end
		end
		return list
	else
		for _, p in Players:GetPlayers() do
			if string.find(string.lower(p.Name), token, 1, true) then
				table.insert(list, p)
			end
		end
		if strict and #list == 0 then error("No players matched '" .. token .. "'") end
		return list
	end
end

return Utils

