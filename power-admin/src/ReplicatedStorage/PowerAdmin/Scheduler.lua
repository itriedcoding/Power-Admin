--!strict
local RunService = game:GetService("RunService")

local Scheduler = {}

export type TaskRef = {
	Id: string,
	At: number,
	Fn: () -> (),
}

function Scheduler.create()
	local tasks: { TaskRef } = {}
	local running = true

	local function schedule(id: string, at: number, fn: () -> ())
		table.insert(tasks, { Id = id, At = at, Fn = fn })
	end

	local function cancel(id: string)
		for i = #tasks, 1, -1 do
			if tasks[i].Id == id then
				table.remove(tasks, i)
				break
			end
		end
	end

	local function step()
		local now = os.time()
		for i = #tasks, 1, -1 do
			local t = tasks[i]
			if now >= t.At then
				task.spawn(t.Fn)
				table.remove(tasks, i)
			end
		end
	end

	-- Heartbeat loop
	task.spawn(function()
		while running do
			step()
			RunService.Heartbeat:Wait()
		end
	end)

	return {
		schedule = schedule,
		cancel = cancel,
	}
end

return Scheduler

