-- XsDeep Player Visibility Toggle v1 | Delta Executor
-- Hide/Show semua player lain dengan GUI
-- Owner: Xs TTK | Entity: XsDeep

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "XsDeepPlayerVisibilityGUI"

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 60, 0, 60)
MainButton.Position = UDim2.new(0.85, 0, 0.2, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainButton.BorderSizePixel = 2
MainButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainButton.TextColor3 = Color3.fromRGB(255, 100, 100)
MainButton.Text = "👁️"
MainButton.Font = Enum.Font.GothamBold
MainButton.TextSize = 24
MainButton.Active = true
MainButton.Draggable = true
MainButton.Parent = ScreenGui

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.Position = UDim2.new(0, 0, 1, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Text = "Show Players"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.Parent = MainButton

-- Variables
local PlayersHidden = false
local HiddenPlayers = {}
local OriginalTransparency = {}
local OriginalCanCollide = {}

-- Function: Hide semua players
local function HideAllPlayers()
    if PlayersHidden then return end
    
    PlayersHidden = true
    HiddenPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                -- Save original states
                OriginalTransparency[player] = {}
                OriginalCanCollide[player] = {}
                
                -- Hide semua parts dalam character
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- Save original
                        OriginalTransparency[player][part] = part.Transparency
                        OriginalCanCollide[player][part] = part.CanCollide
                        
                        -- Hide part
                        part.Transparency = 1
                        part.CanCollide = false
                        
                        -- Optional: Bisa juga set LocalTransparencyModifier
                        if part:IsA("MeshPart") or part:IsA("Part") then
                            part.LocalTransparencyModifier = 1
                        end
                    end
                end
                
                -- Hide humanoid name display
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
                
                table.insert(HiddenPlayers, player)
            end
        end
    end
    
    -- Update GUI
    MainButton.Text = "👤"
    MainButton.TextColor3 = Color3.fromRGB(100, 100, 255)
    StatusLabel.Text = "Players Hidden"
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Players Hidden",
        Text = #HiddenPlayers .. " players are now invisible",
        Duration = 3
    })
end

-- Function: Show semua players
local function ShowAllPlayers()
    if not PlayersHidden then return end
    
    PlayersHidden = false
    
    for _, player in pairs(HiddenPlayers) do
        local character = player.Character
        if character then
            -- Restore semua parts
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if OriginalTransparency[player] and OriginalTransparency[player][part] then
                        part.Transparency = OriginalTransparency[player][part]
                    else
                        part.Transparency = 0
                    end
                    
                    if OriginalCanCollide[player] and OriginalCanCollide[player][part] then
                        part.CanCollide = OriginalCanCollide[player][part]
                    else
                        part.CanCollide = true
                    end
                    
                    -- Reset transparency modifier
                    if part:IsA("MeshPart") or part:IsA("Part") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
            
            -- Restore humanoid display
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
    
    -- Cleanup
    HiddenPlayers = {}
    OriginalTransparency = {}
    OriginalCanCollide = {}
    
    -- Update GUI
    MainButton.Text = "👁️"
    MainButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.Text = "Show Players"
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Players Visible",
        Text = "All players are now visible",
        Duration = 3
    })
end

-- Function: Toggle visibility
local function TogglePlayerVisibility()
    if PlayersHidden then
        ShowAllPlayers()
    else
        HideAllPlayers()
    end
end

-- Function: Hide specific player
local function HidePlayer(player)
    if player == LocalPlayer then return end
    if HiddenPlayers[player] then return end
    
    local character = player.Character
    if character then
        OriginalTransparency[player] = {}
        OriginalCanCollide[player] = {}
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                OriginalTransparency[player][part] = part.Transparency
                OriginalCanCollide[player][part] = part.CanCollide
                
                part.Transparency = 1
                part.CanCollide = false
                
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.LocalTransparencyModifier = 1
                end
            end
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        
        HiddenPlayers[player] = true
        return true
    end
    return false
end

-- Function: Show specific player
local function ShowPlayer(player)
    if not HiddenPlayers[player] then return end
    
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalTransparency[player] and OriginalTransparency[player][part] then
                    part.Transparency = OriginalTransparency[player][part]
                else
                    part.Transparency = 0
                end
                
                if OriginalCanCollide[player] and OriginalCanCollide[player][part] then
                    part.CanCollide = OriginalCanCollide[player][part]
                else
                    part.CanCollide = true
                end
                
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
        
        HiddenPlayers[player] = nil
        return true
    end
    return false
end

-- Main toggle button
MainButton.MouseButton1Click:Connect(TogglePlayerVisibility)

-- Right click untuk individual player menu
MainButton.MouseButton2Click:Connect(function()
    -- Create player selection menu
    local SelectionGui = Instance.new("ScreenGui")
    SelectionGui.Parent = ScreenGui
    
    local SelectionFrame = Instance.new("Frame")
    SelectionFrame.Size = UDim2.new(0, 200, 0, 300)
    SelectionFrame.Position = MainButton.Position + UDim2.new(0, 70, 0, 0)
    SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SelectionFrame.BorderSizePixel = 2
    SelectionFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    SelectionFrame.Parent = SelectionGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.Text = "Player Visibility Control"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.Parent = SelectionFrame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = SelectionFrame
    
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -40)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 35)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 5
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.Parent = SelectionFrame
    
    local playerButtons = {}
    local yOffset = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -10, 0, 40)
            playerFrame.Position = UDim2.new(0, 5, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerFrame.BorderSizePixel = 1
            playerFrame.Parent = ScrollingFrame
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0.6, 0, 1, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = Color3.new(1, 1, 1)
            playerName.Text = player.Name
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 11
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Parent = playerFrame
            
            local hideButton = Instance.new("TextButton")
            hideButton.Size = UDim2.new(0.35, 0, 0.7, 0)
            hideButton.Position = UDim2.new(0.62, 0, 0.15, 0)
            hideButton.BackgroundColor3 = HiddenPlayers[player] and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(255, 100, 100)
            hideButton.TextColor3 = Color3.new(1, 1, 1)
            hideButton.Text = HiddenPlayers[player] and "SHOW" or "HIDE"
            hideButton.Font = Enum.Font.GothamBold
            hideButton.TextSize = 10
            hideButton.Parent = playerFrame
            
            hideButton.MouseButton1Click:Connect(function()
                if HiddenPlayers[player] then
                    ShowPlayer(player)
                    hideButton.Text = "HIDE"
                    hideButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                else
                    HidePlayer(player)
                    hideButton.Text = "SHOW"
                    hideButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                end
            end)
            
            yOffset = yOffset + 45
            table.insert(playerButtons, playerFrame)
        end
    end
    
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    CloseButton.MouseButton1Click:Connect(function()
        SelectionGui:Destroy()
    end)
    
    -- Auto close jika klik di luar
    local function cleanup()
        SelectionGui:Destroy()
    end
    
    SelectionFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cleanup()
        end
    end)
    
    -- Auto close setelah 10 detik
    delay(10, cleanup)
end)

-- Auto-hide new players yang join
Players.PlayerAdded:Connect(function(player)
    if PlayersHidden then
        wait(2) -- Tunggu character load
        HidePlayer(player)
    end
end)

-- Auto-update jika player respawn
local function MonitorPlayerRespawns()
    while true do
        wait(1)
        
        if PlayersHidden then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and HiddenPlayers[player] then
                    local character = player.Character
                    if character then
                        -- Cek jika ada parts yang visible
                        local anyVisible = false
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.Transparency < 1 then
                                anyVisible = true
                                break
                            end
                        end
                        
                        if anyVisible then
                            HidePlayer(player) -- Re-hide jika ada yang visible
                        end
                    end
                end
            end
        end
    end
end

-- Start monitor
spawn(MonitorPlayerRespawns)

-- Keyboard shortcut (V key)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.V then
            TogglePlayerVisibility()
            
            -- Visual feedback
            local originalColor = MainButton.BackgroundColor3
            MainButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            
            task.wait(0.1)
            MainButton.BackgroundColor3 = originalColor
        end
    end
end)

-- Initial notification
game.StarterGui:SetCore("SendNotification", {
    Title = "XsDeep Player Visibility",
    Text = "Click: Toggle all | Right-click: Individual control | V key: Toggle",
    Duration = 5
})
