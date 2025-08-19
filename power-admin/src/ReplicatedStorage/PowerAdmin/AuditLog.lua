--!strict
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local AuditLog = {}

export type AuditEntry = {
	id: string,
	timestamp: number,
	actorUserId: number?,
	action: string,
	args: any,
	targets: { number }?,
	success: boolean,
	message: string?,
}

function AuditLog.create(config)
	local memoryLog: { AuditEntry } = {}
	local maxMemory = 500
	local dsScope = config.DataStore.Scope
	local dsName = config.DataStore.AuditStore
	local ds = DataStoreService:GetDataStore(dsName, dsScope)
    local webhookUrl = (config.FeatureFlags.UseWebhooks and config.Webhook and #config.Webhook > 0) and config.Webhook or nil

	local function append(entry: AuditEntry)
		entry.id = entry.id or HttpService:GenerateGUID(false)
		table.insert(memoryLog, entry)
		if #memoryLog > maxMemory then
			table.remove(memoryLog, 1)
		end
		-- Best-effort async write
		task.spawn(function()
			pcall(function()
				ds:UpdateAsync("recent", function(state)
					state = state or {}
					table.insert(state, entry)
					if #state > 2000 then
						for _ = 1, #state - 2000 do
							table.remove(state, 1)
						end
					end
					return state
				end)
			end)

			-- Optional webhook
			if webhookUrl then
				pcall(function()
					HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(entry), Enum.HttpContentType.ApplicationJson)
				end)
			end
		end)
	end

	local function getRecent(limit: number?): { AuditEntry }
		local n = math.clamp(limit or 100, 1, maxMemory)
		local result: { AuditEntry } = {}
		for i = math.max(1, #memoryLog - n + 1), #memoryLog do
			table.insert(result, memoryLog[i])
		end
		return result
	end

	return {
		append = append,
		getRecent = getRecent,
	}
end

return AuditLog

