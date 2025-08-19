--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local remotesFolder = ReplicatedStorage:WaitForChild("PowerAdmin_Remotes")
local evRun = remotesFolder:WaitForChild("RunCommand") :: RemoteEvent
local fnQuery = remotesFolder:WaitForChild("Query") :: RemoteFunction
local evLog = remotesFolder:WaitForChild("LogFeed") :: RemoteEvent

-- UI
local screen = Instance.new("ScreenGui")
screen.Name = "PowerAdmin"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromScale(0.45, 0.5)
panel.Position = UDim2.fromScale(0.02, 0.08)
panel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Parent = screen

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundTransparency = 1
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextColor3 = Color3.fromRGB(235, 235, 235)
header.Text = "  Power Admin"
header.Parent = panel

local tabs = Instance.new("Frame")
tabs.Position = UDim2.new(0, 0, 0, 28)
tabs.Size = UDim2.new(1, 0, 0, 28)
tabs.BackgroundTransparency = 1
tabs.Parent = panel

local tabButtons: { [string]: TextButton } = {}
local tabPages: { [string]: Frame } = {}
local activeTab = "Console"

local function createTab(name: string)
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Parent = tabs
    if next(tabButtons) == nil then
        btn.Position = UDim2.new(0, 6, 0, 0)
    else
        local count = 0
        for _ in pairs(tabButtons) do count += 1 end
        btn.Position = UDim2.new(0, 6 + 86 * count, 0, 0)
    end
    local page = Instance.new("Frame")
    page.Name = name
    page.Position = UDim2.new(0, 0, 0, 56)
    page.Size = UDim2.new(1, 0, 1, -56)
    page.BackgroundTransparency = 1
    page.Visible = name == activeTab
    page.Parent = panel
    tabButtons[name] = btn
    tabPages[name] = page
    btn.MouseButton1Click:Connect(function()
        for n, p in tabPages do
            p.Visible = n == name
        end
        activeTab = name
    end)
end

createTab("Console")
createTab("Players")
createTab("Logs")
createTab("Settings")

-- Console Page
local consolePage = tabPages["Console"]

local output = Instance.new("ScrollingFrame")
output.Name = "Output"
output.Size = UDim2.new(1, -10, 1, -40)
output.Position = UDim2.new(0, 5, 0, 5)
output.BorderSizePixel = 0
output.BackgroundTransparency = 1
output.CanvasSize = UDim2.new(0, 0, 0, 0)
output.ScrollBarThickness = 6
output.Parent = consolePage

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = output
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

local input = Instance.new("TextBox")
input.PlaceholderText = ";help or ;cmds"
input.ClearTextOnFocus = false
input.Size = UDim2.new(1, -10, 0, 30)
input.Position = UDim2.new(0, 5, 1, -35)
input.TextXAlignment = Enum.TextXAlignment.Left
input.TextSize = 16
input.Font = Enum.Font.Gotham
input.TextColor3 = Color3.fromRGB(240, 240, 240)
input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
input.BorderSizePixel = 0
input.Parent = consolePage

local history: { string } = {}
local historyIndex = 0
local registryCache: { [string]: any } = {}

local function fetchRegistry()
    if next(registryCache) == nil then
        local data = fnQuery:InvokeServer("listCommands", {})
        if data and data.ok and type(data.cmds) == "table" then
            registryCache = data.cmds
        end
    end
    return registryCache
end

local function getCommandNames()
    local list = {}
    for name in pairs(fetchRegistry()) do table.insert(list, name) end
    table.sort(list)
    return list
end

local function pushLine(text: string, isError: boolean?)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = isError and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(210, 210, 210)
    label.Text = text
    label.Parent = output
    task.wait()
    output.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    output.CanvasPosition = Vector2.new(0, math.max(0, output.CanvasSize.Y.Offset - output.AbsoluteSize.Y))
end

input.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local text = input.Text
    if text == "" then return end
    table.insert(history, 1, text)
    historyIndex = 0
    pushLine("> " .. text)
    input.Text = ""
    evRun:FireServer(text)
end)

UserInputService.InputBegan:Connect(function(io, gpe)
    if gpe then return end
    if io.KeyCode == Enum.KeyCode.Slash then
        if not input:IsFocused() then
            input:CaptureFocus()
            input.CursorPosition = #input.Text + 1
        end
    elseif io.KeyCode == Enum.KeyCode.Up then
        if input:IsFocused() then
            historyIndex = math.clamp(historyIndex + 1, 0, #history)
            if historyIndex > 0 then input.Text = history[historyIndex] end
        end
    elseif io.KeyCode == Enum.KeyCode.Down then
        if input:IsFocused() then
            historyIndex = math.clamp(historyIndex - 1, 0, #history)
            if historyIndex > 0 then input.Text = history[historyIndex] else input.Text = "" end
        end
    end
end)

-- Logs Page
local logsPage = tabPages["Logs"]
local logsList = Instance.new("ScrollingFrame")
logsList.Size = UDim2.new(1, -10, 1, -10)
logsList.Position = UDim2.new(0, 5, 0, 5)
logsList.BorderSizePixel = 0
logsList.BackgroundTransparency = 1
logsList.ScrollBarThickness = 6
logsList.Parent = logsPage

local logsLayout = Instance.new("UIListLayout")
logsLayout.Parent = logsList
logsLayout.FillDirection = Enum.FillDirection.Vertical
logsLayout.SortOrder = Enum.SortOrder.LayoutOrder
logsLayout.Padding = UDim.new(0, 4)

local function addLog(entry)
    local text = string.format("[%s] %s %s %s", os.date("!%H:%M:%S", entry.timestamp or os.time()), tostring(entry.actorUserId or "SYSTEM"), tostring(entry.action or ""), tostring(entry.message or ""))
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = entry.success and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 200, 200)
    lbl.Text = text
    lbl.Parent = logsList
    task.wait()
    logsList.CanvasSize = UDim2.new(0, 0, 0, logsLayout.AbsoluteContentSize.Y + 20)
    logsList.CanvasPosition = Vector2.new(0, math.max(0, logsList.CanvasSize.Y.Offset - logsList.AbsoluteSize.Y))
end

local recent = fnQuery:InvokeServer("getRecentLogs", {})
if recent and recent.ok then
    for _, entry in ipairs(recent.logs) do addLog(entry) end
end

evLog.OnClientEvent:Connect(function(entry)
    addLog(entry)
end)

-- Simple Autocomplete dropdown
do
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0, 220, 0, 120)
    dropdown.Position = UDim2.new(0, 8, 1, -165)
    dropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.Parent = consolePage

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -6, 1, -6)
    list.Position = UDim2.new(0, 3, 0, 3)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 6
    list.Parent = dropdown

    local layout = Instance.new("UIListLayout")
    layout.Parent = list
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)

    local function populate(prefix: string)
        for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local names = getCommandNames()
        local count = 0
        for _, name in ipairs(names) do
            if string.find(name, prefix, 1, true) == 1 then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 22)
                btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                btn.BorderSizePixel = 0
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.TextColor3 = Color3.fromRGB(230, 230, 230)
                btn.Text = name
                btn.Parent = list
                btn.MouseButton1Click:Connect(function()
                    input.Text = ";" .. name .. " "
                    input:CaptureFocus()
                    input.CursorPosition = #input.Text + 1
                    dropdown.Visible = false
                end)
                count += 1
            end
        end
        task.wait()
        list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        dropdown.Visible = count > 0
    end

    input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = input.Text
        if string.sub(text, 1, 1) ~= ";" then dropdown.Visible = false return end
        local after = string.match(text, ";([^%s]*)") or ""
        populate(after)
    end)
end

-- Players Page (simple roster)
local playersPage = tabPages["Players"]
local roster = Instance.new("ScrollingFrame")
roster.Size = UDim2.new(1, -10, 1, -10)
roster.Position = UDim2.new(0, 5, 0, 5)
roster.BorderSizePixel = 0
roster.BackgroundTransparency = 1
roster.ScrollBarThickness = 6
roster.Parent = playersPage

local rosterLayout = Instance.new("UIListLayout")
rosterLayout.Parent = roster
rosterLayout.FillDirection = Enum.FillDirection.Vertical
rosterLayout.SortOrder = Enum.SortOrder.LayoutOrder
rosterLayout.Padding = UDim.new(0, 4)

local function refreshRoster()
    for _, child in ipairs(roster:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.Text = string.format("%s (%d)", p.Name, p.UserId)
        btn.Parent = roster
        btn.MouseButton1Click:Connect(function()
            activeTab = "Console"
            for n, page in tabPages do page.Visible = n == "Console" end
            input.Text = ";tp me name:" .. p.Name
            input:CaptureFocus()
            input.CursorPosition = #input.Text + 1
        end)
    end
    task.wait()
    roster.CanvasSize = UDim2.new(0, 0, 0, rosterLayout.AbsoluteContentSize.Y + 20)
end

refreshRoster()
Players.PlayerAdded:Connect(refreshRoster)
Players.PlayerRemoving:Connect(refreshRoster)

-- Settings Page (read-only role display for now)
local settingsPage = tabPages["Settings"]
local roleLabel = Instance.new("TextLabel")
roleLabel.Size = UDim2.new(1, -10, 0, 24)
roleLabel.Position = UDim2.new(0, 5, 0, 8)
roleLabel.BackgroundTransparency = 1
roleLabel.TextXAlignment = Enum.TextXAlignment.Left
roleLabel.Font = Enum.Font.Gotham
roleLabel.TextSize = 16
roleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
roleLabel.Text = "Role: ..."
roleLabel.Parent = settingsPage

local myRole = fnQuery:InvokeServer("getMyRole", {})
if myRole and myRole.ok then
    roleLabel.Text = "Role: " .. tostring(myRole.role)
end

-- Draggable header
do
    local dragging = false
    local startPos = Vector2.new()
    local startFrame = Vector2.new()
    header.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = io.Position
            startFrame = Vector2.new(panel.Position.X.Scale, panel.Position.Y.Scale)
        end
    end)
    header.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and io.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = io.Position - startPos
            panel.Position = UDim2.fromScale(startFrame.X + (delta.X / workspace.CurrentCamera.ViewportSize.X), startFrame.Y + (delta.Y / workspace.CurrentCamera.ViewportSize.Y))
        end
    end)
end

return true

