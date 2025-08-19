--!strict
local DataStoreService = game:GetService("DataStoreService")

local Whitelist = {}

function Whitelist.create(config)
	local store = DataStoreService:GetDataStore("Whitelist", config.DataStore.Scope)
	local cache: { [number]: boolean } = {}

	local function load()
		pcall(function()
			local data = store:GetAsync("list")
			if type(data) == "table" then
				cache = {}
				for _, id in ipairs(data) do cache[tonumber(id)] = true end
			end
		end)
	end

	local function save()
		local ids = {}
		for id, ok in pairs(cache) do if ok then table.insert(ids, id) end end
		pcall(function()
			store:SetAsync("list", ids)
		end)
	end

	local function add(userId: number)
		cache[userId] = true
		save()
	end

	local function remove(userId: number)
		cache[userId] = nil
		save()
	end

	local function isWhitelisted(userId: number): boolean
		return cache[userId] == true
	end

	local function listAll(): { number }
		local out = {}
		for id, ok in pairs(cache) do if ok then table.insert(out, id) end end
		return out
	end

	load()
	return { load = load, save = save, add = add, remove = remove, isWhitelisted = isWhitelisted, list = listAll }
end

return Whitelist

