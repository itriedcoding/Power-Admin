--!strict
local Players = game:GetService("Players")

local Targeting = {}

function Targeting.find(actor: Player, token: string): { Player }
	local lower = string.lower(token)
	local targets: { Player } = {}
	if lower == "me" then
		return { actor }
	elseif lower == "all" then
		return Players:GetPlayers()
	elseif lower == "others" then
		for _, p in Players:GetPlayers() do if p ~= actor then table.insert(targets, p) end end
		return targets
	elseif string.find(lower, "name:") == 1 then
		local name = string.sub(lower, 6)
		for _, p in Players:GetPlayers() do if string.find(string.lower(p.Name), name, 1, true) then table.insert(targets, p) end end
		return targets
	elseif string.find(lower, "team:") == 1 then
		local teamName = string.sub(lower, 6)
		for _, p in Players:GetPlayers() do if p.Team and string.lower(p.Team.Name) == teamName then table.insert(targets, p) end end
		return targets
	else
		for _, p in Players:GetPlayers() do if string.find(string.lower(p.Name), lower, 1, true) then table.insert(targets, p) end end
		return targets
	end
end

return Targeting

