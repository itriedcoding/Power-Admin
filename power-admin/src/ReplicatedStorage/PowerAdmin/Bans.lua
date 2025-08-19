--!strict
local DataStoreService = game:GetService("DataStoreService")

local Bans = {}

export type BanEntry = { untilTs: number, reason: string }

function Bans.create(config)
	local store = DataStoreService:GetDataStore(config.DataStore.BanStore, config.DataStore.Scope)
	local cache: { [number]: BanEntry } = {}

	local function load()
		pcall(function()
			local data = store:GetAsync("banned")
			if type(data) == "table" then cache = data end
		end)
	end

	local function save()
		pcall(function()
			store:SetAsync("banned", cache)
		end)
	end

	local function add(userId: number, untilTs: number, reason: string)
		cache[userId] = { untilTs = untilTs, reason = reason }
		save()
	end

	local function remove(userId: number)
		cache[userId] = nil
		save()
	end

	local function isBanned(userId: number): (boolean, string?)
		local entry = cache[userId]
		if not entry then return false, nil end
		if entry.untilTs == 0 then return true, entry.reason end
		if os.time() < entry.untilTs then return true, entry.reason end
		cache[userId] = nil
		save()
		return false, nil
	end

	load()
	return { load = load, save = save, add = add, remove = remove, isBanned = isBanned }
end

return Bans

