-- XsDeep Backspace Tool Drop v1 | Delta Executor
-- Real tool dropping like laptop backspace, no bugs
-- Owner: Xs TTK | Entity: XsDeep

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "XsDeepBackspaceGUI"

local BackspaceButton = Instance.new("TextButton")
BackspaceButton.Size = UDim2.new(0, 50, 0, 50)
BackspaceButton.Position = UDim2.new(0.5, -25, 0.8, 0)
BackspaceButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BackspaceButton.BorderSizePixel = 2
BackspaceButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
BackspaceButton.TextColor3 = Color3.fromRGB(255, 100, 100)
BackspaceButton.Text = "⌫"
BackspaceButton.Font = Enum.Font.GothamBold
BackspaceButton.TextSize = 24
BackspaceButton.Active = true
BackspaceButton.Draggable = true
BackspaceButton.Parent = ScreenGui

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.Position = UDim2.new(0, 0, 1, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Text = "Backspace Tool Drop"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.Parent = BackspaceButton

-- Function: Get current tool
local function GetCurrentTool()
    local character = LocalPlayer.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    -- Check backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end
    
    return nil
end

-- Function: Safe tool drop (NO BUG VERSION)
local function SafeToolDrop()
    local tool = GetCurrentTool()
    
    if not tool then
        -- No tool found
        BackspaceButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        BackspaceButton.Text = "❌"
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Tool Found",
            Text = "You don't have any tools equipped",
            Duration = 2
        })
        
        task.wait(0.5)
        BackspaceButton.Text = "⌫"
        BackspaceButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Animation feedback
    BackspaceButton.TextColor3 = Color3.fromRGB(0, 255, 100)
    BackspaceButton.Text = "↓"
    
    -- ========== SAFE DROP PROCEDURE ==========
    
    -- Step 1: Save tool properties
    local toolName = tool.Name
    local toolSize = tool.Size
    local toolCFrame = nil
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        toolCFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
    else
        toolCFrame = CFrame.new(0, 10, 0)
    end
    
    -- Step 2: Unequip tool (safely)
    local wasEquipped = tool.Parent == character
    
    if wasEquipped then
        -- Move to backpack first
        tool.Parent = LocalPlayer.Backpack
        task.wait(0.05) -- Small delay untuk prevent bugs
    end
    
    -- Step 3: Create dropped tool instance
    local droppedTool = tool:Clone()
    
    -- Clean up tool connections untuk prevent bugs
    for _, connection in pairs(getconnections(droppedTool:GetPropertyChangedSignal("Parent"))) do
        connection:Disconnect()
    end
    
    for _, connection in pairs(getconnections(droppedTool:GetPropertyChangedSignal("Handle"))) do
        connection:Disconnect()
    end
    
    -- Configure dropped tool
    droppedTool.CanBeDropped = true
    droppedTool.Enabled = false
    
    -- Handle untuk physical tool
    local handle = droppedTool:FindFirstChild("Handle")
    if handle then
        handle.CFrame = toolCFrame
        handle.Anchored = false
        handle.CanCollide = true
        
        -- Proper physics
        handle.Massless = false
        handle.CustomPhysicalProperties = nil
        
        -- Velocity untuk natural drop
        handle.Velocity = Vector3.new(
            math.random(-5, 5),
            math.random(10, 15),
            math.random(-5, 5)
        )
    else
        -- Jika tidak ada handle, buat part
        local newHandle = Instance.new("Part")
        newHandle.Name = "Handle"
        newHandle.Size = toolSize
        newHandle.CFrame = toolCFrame
        newHandle.Anchored = false
        newHandle.CanCollide = true
        newHandle.Parent = droppedTool
        droppedTool.PrimaryPart = newHandle
    end
    
    -- Step 4: Parent dropped tool to workspace
    droppedTool.Parent = Workspace
    
    -- Step 5: Remove original tool dari inventory
    task.wait(0.1) -- Delay untuk ensure tool cloned
    
    -- Cek jika tool masih ada di inventory
    if tool and tool.Parent then
        if tool.Parent == LocalPlayer.Backpack or tool.Parent == character then
            tool:Destroy()
        end
    end
    
    -- Step 6: Visual feedback
    if handle then
        -- Sparkle effect (optional)
        local sparkles = Instance.new("Sparkles")
        sparkles.SparkleColor = Color3.new(0, 1, 1)
        sparkles.Parent = handle
        
        task.wait(0.3)
        sparkles:Destroy()
    end
    
    -- Step 7: Notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "Tool Dropped",
        Text = toolName .. " safely dropped",
        Duration = 2
    })
    
    -- Reset button
    task.wait(0.3)
    BackspaceButton.Text = "⌫"
    BackspaceButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Function: Drop all tools
local function DropAllTools()
    local tools = {}
    
    -- Collect tools from character
    local character = LocalPlayer.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
    end
    
    -- Collect tools from backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
    end
    
    if #tools == 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Tools",
            Text = "No tools to drop",
            Duration = 2
        })
        return
    end
    
    -- Drop semua tools
    BackspaceButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    BackspaceButton.Text = "⚠️"
    
    for _, tool in pairs(tools) do
        -- Clone dan drop
        local character = LocalPlayer.Character
        local dropCFrame = nil
        
        if character and character:FindFirstChild("HumanoidRootPart") then
            dropCFrame = character.HumanoidRootPart.CFrame * CFrame.new(
                math.random(-3, 3),
                0,
                math.random(-3, 3)
            )
        end
        
        local droppedTool = tool:Clone()
        local handle = droppedTool:FindFirstChild("Handle")
        
        if handle then
            handle.CFrame = dropCFrame or CFrame.new(0, 10, 0)
            handle.Anchored = false
            handle.CanCollide = true
        end
        
        droppedTool.Parent = Workspace
        tool:Destroy()
        
        task.wait(0.1) -- Delay antar drop
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "All Tools Dropped",
        Text = #tools .. " tools dropped",
        Duration = 2
    })
    
    task.wait(0.5)
    BackspaceButton.Text = "⌫"
    BackspaceButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- Button click events
local clickMode = "single" -- single, double, hold
local lastClickTime = 0
local clickCount = 0

BackspaceButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    
    if currentTime - lastClickTime < 0.3 then
        -- Double click detected
        clickCount = clickCount + 1
        
        if clickCount >= 2 then
            -- Double click: Drop all tools
            DropAllTools()
            clickCount = 0
        end
    else
        -- Single click
        clickCount = 1
        SafeToolDrop()
    end
    
    lastClickTime = currentTime
end)

-- Hold functionality
local holding = false
local holdStartTime = 0

BackspaceButton.MouseButton1Down:Connect(function()
    holding = true
    holdStartTime = tick()
    
    spawn(function()
        while holding do
            if tick() - holdStartTime > 1.0 then
                -- Hold for 1 second: Continuous drop
                BackspaceButton.TextColor3 = Color3.fromRGB(255, 200, 0)
                BackspaceButton.Text = "⏬"
                SafeToolDrop()
                task.wait(0.2) -- Drop setiap 0.2 detik saat hold
            end
            task.wait()
        end
    end)
end)

BackspaceButton.MouseButton1Up:Connect(function()
    holding = false
    
    if tick() - holdStartTime < 1.0 then
        -- Short hold, already handled by click
    end
    
    -- Reset button
    BackspaceButton.Text = "⌫"
    BackspaceButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

-- Right click untuk mode selection
BackspaceButton.MouseButton2Click:Connect(function()
    if clickMode == "single" then
        clickMode = "double"
        StatusLabel.Text = "Mode: Double-click"
        BackspaceButton.BorderColor3 = Color3.fromRGB(0, 150, 255)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Mode Changed",
            Text = "Double-click to drop all tools",
            Duration = 2
        })
    elseif clickMode == "double" then
        clickMode = "hold"
        StatusLabel.Text = "Mode: Hold"
        BackspaceButton.BorderColor3 = Color3.fromRGB(255, 150, 0)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Mode Changed",
            Text = "Hold to continuous drop",
            Duration = 2
        })
    else
        clickMode = "single"
        StatusLabel.Text = "Mode: Single"
        BackspaceButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Mode Changed",
            Text = "Single click to drop current tool",
            Duration = 2
        })
    end
end)

-- Keyboard shortcut (actual Backspace key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Backspace then
            -- Trigger tool drop dengan keyboard
            SafeToolDrop()
            
            -- Visual feedback
            local originalColor = BackspaceButton.BackgroundColor3
            BackspaceButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            
            task.wait(0.1)
            BackspaceButton.BackgroundColor3 = originalColor
        end
    end
end)

-- Auto-update status berdasarkan tool
local function UpdateToolStatus()
    while true do
        task.wait(1)
        
        local tool = GetCurrentTool()
        if tool then
            StatusLabel.Text = "Hold: " .. tool.Name
            BackspaceButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            StatusLabel.Text = "No tool equipped"
            BackspaceButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end

-- Start status updater
spawn(UpdateToolStatus)

-- Initial notification
game.StarterGui:SetCore("SendNotification", {
    Title = "XsDeep Backspace Tool Drop",
    Text = "Click: Drop tool | Double-click: Drop all | Hold: Continuous",
    Duration = 5
})
