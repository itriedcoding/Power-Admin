--!strict
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local Warnings = {}

export type WarningEntry = { id: string, by: number?, at: number, reason: string? }

function Warnings.create(config)
	local store = DataStoreService:GetDataStore("Warnings", config.DataStore.Scope)

	local function getKey(userId: number): string
		return tostring(userId)
	end

	local function list(userId: number): { WarningEntry }
		local ok, data = pcall(function()
			return store:GetAsync(getKey(userId))
		end)
		if ok and type(data) == "table" then return data end
		return {}
	end

	local function add(userId: number, by: number?, reason: string?)
		local entries = list(userId)
		table.insert(entries, { id = HttpService:GenerateGUID(false), by = by, at = os.time(), reason = reason })
		pcall(function()
			store:SetAsync(getKey(userId), entries)
		end)
	end

	local function clear(userId: number)
		pcall(function()
			store:RemoveAsync(getKey(userId))
		end)
	end

	local function removeOne(userId: number)
		local entries = list(userId)
		if #entries > 0 then table.remove(entries, #entries) end
		pcall(function()
			store:SetAsync(getKey(userId), entries)
		end)
	end

	local function count(userId: number): number
		return #list(userId)
	end

	return { list = list, add = add, clear = clear, removeOne = removeOne, count = count }
end

return Warnings

