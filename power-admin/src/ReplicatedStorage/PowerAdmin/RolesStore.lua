--!strict
local DataStoreService = game:GetService("DataStoreService")

local RolesStore = {}

function RolesStore.create(config, roleResolver)
	local store = DataStoreService:GetDataStore("Roles", config.DataStore.Scope)
	local cache: { [number]: string } = {}

	local function load(userId: number)
		local ok, value = pcall(function()
			return store:GetAsync(tostring(userId))
		end)
		if ok and type(value) == "string" then
			cache[userId] = value
			roleResolver.setRole(userId, value)
		end
	end

	local function save(userId: number, roleName: string)
		cache[userId] = roleName
		pcall(function()
			store:SetAsync(tostring(userId), roleName)
		end)
	end

	return { load = load, save = save }
end

return RolesStore

