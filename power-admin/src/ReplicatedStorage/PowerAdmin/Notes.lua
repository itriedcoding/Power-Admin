--!strict
local DataStoreService = game:GetService("DataStoreService")

local Notes = {}

export type NoteEntry = { by: number?, at: number, text: string }

function Notes.create(config)
	local store = DataStoreService:GetDataStore("Notes", config.DataStore.Scope)

	local function key(userId: number): string
		return tostring(userId)
	end

	local function list(userId: number): { NoteEntry }
		local ok, data = pcall(function()
			return store:GetAsync(key(userId))
		end)
		if ok and type(data) == "table" then return data end
		return {}
	end

	local function add(userId: number, by: number?, text: string)
		local entries = list(userId)
		table.insert(entries, { by = by, at = os.time(), text = text })
		pcall(function()
			store:SetAsync(key(userId), entries)
		end)
	end

	local function clear(userId: number)
		pcall(function()
			store:RemoveAsync(key(userId))
		end)
	end

	return { list = list, add = add, clear = clear }
end

return Notes

