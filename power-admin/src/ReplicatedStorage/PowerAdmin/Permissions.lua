--!strict
local Players = game:GetService("Players")

local Permissions = {}

local function isOwner(userId: number, owners: { number }): boolean
	for _, id in owners do
		if id == userId then
			return true
		end
	end
	return false
end

function Permissions.buildUserRoleResolver(config)
	local defaultRole = config.DefaultRole
	local owners = config.Owners
	local roles = config.Roles

	local userIdToRole: { [number]: string } = {}

	local function setRole(userId: number, roleName: string)
		userIdToRole[userId] = roleName
	end

	local function getRole(userId: number): string
		if isOwner(userId, owners) then
			return "Owner"
		end
		return userIdToRole[userId] or defaultRole
	end

	local function getRoleWeight(roleName: string): number
		local role = roles[roleName]
		return role and role.Weight or 0
	end

	local function userHasPermission(userId: number, permission: string): boolean
		if isOwner(userId, owners) then
			return true
		end
		local roleName = getRole(userId)
		local role = roles[roleName]
		if not role then
			return false
		end
		for _, perm in role.Permissions do
			if perm == "*" or perm == permission then
				return true
			end
			-- support namespace wildcard like players.*
			if string.sub(perm, -2) == ".*" then
				local prefix = string.sub(perm, 1, #perm - 1)
				if string.sub(permission, 1, #prefix) == prefix then
					return true
				end
			end
		end
		return false
	end

	return {
		setRole = setRole,
		getRole = getRole,
		getRoleWeight = getRoleWeight,
		userHasPermission = userHasPermission,
	}
end

return Permissions

