--!strict
local AutoComplete = {}

function AutoComplete.create(fetchRegistry: () -> ({ [string]: any }))
	local history: { string } = {}
	local function suggest(prefix: string): { string }
		local reg = fetchRegistry()
		local list: { string } = {}
		for name, meta in pairs(reg) do
			if string.find(name, prefix, 1, true) == 1 then table.insert(list, name) end
		end
		table.sort(list)
		return list
	end

	local function push(line: string)
		if line ~= "" then table.insert(history, 1, line) end
	end

	return { suggest = suggest, push = push, getHistory = function() return history end }
end

return AutoComplete

