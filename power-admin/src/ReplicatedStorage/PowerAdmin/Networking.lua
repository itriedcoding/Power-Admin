--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networking = {}

function Networking.bootstrap()
	local folder = Instance.new("Folder")
	folder.Name = "PowerAdmin_Remotes"
	folder.Parent = ReplicatedStorage

	local evRun = Instance.new("RemoteEvent")
	evRun.Name = "RunCommand"
	evRun.Parent = folder

	local evQuery = Instance.new("RemoteFunction")
	evQuery.Name = "Query"
	evQuery.Parent = folder

	local evLog = Instance.new("RemoteEvent")
	evLog.Name = "LogFeed"
	evLog.Parent = folder

	return {
		Folder = folder,
		RunCommand = evRun,
		Query = evQuery,
		LogFeed = evLog,
	}
end

return Networking

