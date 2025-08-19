--!strict
local Players = game:GetService("Players")

local GroupAdapter = {}

-- Config.GroupRoles = { [groupId] = { [minRank] = "RoleName", ... } }
function GroupAdapter.autoAssign(config, roleResolver, player: Player)
	local map = config.GroupRoles
	if not map then return end
	for groupId, rankToRole in pairs(map) do
		local ok, rank = pcall(function()
			return player:GetRankInGroup(tonumber(groupId))
		end)
		if ok and type(rank) == "number" then
			local bestRole
			local bestRank = -1
			for minRankStr, roleName in pairs(rankToRole) do
				local minRank = tonumber(minRankStr)
				if minRank and rank >= minRank and minRank > bestRank then
					bestRank = minRank
					bestRole = roleName
				end
			end
			if bestRole then
				roleResolver.setRole(player.UserId, bestRole)
				return
			end
		end
	end
end

return GroupAdapter

