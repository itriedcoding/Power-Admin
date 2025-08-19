--!strict
local ServerState = {}

function ServerState.create()
	local locked = false
	local function isLocked(): boolean return locked end
	local function setLocked(v: boolean) locked = v end
	return { isLocked = isLocked, setLocked = setLocked }
end

return ServerState

