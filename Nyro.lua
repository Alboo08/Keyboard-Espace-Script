-- Xeno Executor Script (BBNO Auto Farm - English & Full Control Lock)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

-- Settings & Control Variables
local autoFarmActive = false
local currentTween = nil
local SPEED = 80
local teleportTarget = Vector3.new(807.2, 810.7, 926.7)
local ACTION_NAME = "DisableAllInputs"

-- Function to completely lock/unlock player movement (Keyboard, Touch, Gamepad)
local function setControlsLocked(locked)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if locked then
        -- 1. Disable Humanoid Walking & Jumping
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.JumpHeight = 0
        end

        -- 2. Sink all Movement & Action Inputs across all devices
        ContextActionService:BindActionAtPriority(
            ACTION_NAME,
            function()
                return Enum.ContextActionResult.Sink
            end,
            false,
            Enum.ContextActionPriority.High.Value + 1000,
            Enum.PlayerActions.CharacterForward,
            Enum.PlayerActions.CharacterBackward,
            Enum.PlayerActions.CharacterLeft,
            Enum.PlayerActions.CharacterRight,
            Enum.PlayerActions.CharacterJump
        )
    else
        -- Restore Humanoid Speed & Unlock Controls
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.JumpHeight = 7.2
        end

        ContextActionService:UnbindAction(ACTION_NAME)
    end
end

-- Remove old GUI if present
if CoreGui:FindFirstChild("BBNO_Farm_GUI") then
    CoreGui.BBNO_Farm_GUI:Destroy()
end

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BBNO_Farm_GUI"
gui.Parent = CoreGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 210)
frame.Position = UDim2.new(0.5, -140, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(45, 48, 58)
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.Text = "🤖 BBNO Auto Farm"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = frame

-- Close Button (X)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -38, 0, 10)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(38, 42, 52)
close.TextColor3 = Color3.fromRGB(200, 200, 200)
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

-- Status Display Container
local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(1, -30, 0, 36)
statusContainer.Position = UDim2.new(0, 15, 0, 50)
statusContainer.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
statusContainer.BorderSizePixel = 0
statusContainer.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = statusContainer

-- Start Button
local farmButton = Instance.new("TextButton")
farmButton.Size = UDim2.new(1, -30, 0, 42)
farmButton.Position = UDim2.new(0, 15, 0, 98)
farmButton.Text = "▶ Start Farm"
farmButton.Font = Enum.Font.GothamBold
farmButton.TextSize = 14
farmButton.BackgroundColor3 = Color3.fromRGB(0, 180, 110)
farmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
farmButton.BorderSizePixel = 0
farmButton.Parent = frame

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 8)
farmCorner.Parent = farmButton

-- Stop Button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -30, 0, 42)
stopButton.Position = UDim2.new(0, 15, 0, 148)
stopButton.Text = "🛑 Stop"
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.BorderSizePixel = 0
stopButton.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

-- Function: Stop All Processes & Unlock Controls
local function stopAll()
    autoFarmActive = false
    setControlsLocked(false)
    
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    statusLabel.Text = "Status: Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
end

close.MouseButton1Click:Connect(function()
    stopAll()
    gui:Destroy()
end)

stopButton.MouseButton1Click:Connect(stopAll)

-- Forward & Backward Movement Routine
local function runVorUndZurueck()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    local distance = 20 * 3.57 -- 20m in studs
    local timeDuration = distance / SPEED

    -- Forward
    local targetForward = root.CFrame * CFrame.new(0, 0, -distance)
    currentTween = TweenService:Create(root, TweenInfo.new(timeDuration, Enum.EasingStyle.Linear), {CFrame = targetForward})
    currentTween:Play()
    currentTween.Completed:Wait()

    if not autoFarmActive then return end

    -- Backward
    local targetBackward = root.CFrame * CFrame.new(0, 0, distance)
    currentTween = TweenService:Create(root, TweenInfo.new(timeDuration, Enum.EasingStyle.Linear), {CFrame = targetBackward})
    currentTween:Play()
    currentTween.Completed:Wait()
end

-- MAIN AUTO FARM LOGIC
farmButton.MouseButton1Click:Connect(function()
    stopAll()
    autoFarmActive = true
    setControlsLocked(true)

    task.spawn(function()
        -- 1. Reset Character
        statusLabel.Text = "Status: Resetting Character..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 190, 50)
        
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = 0
        end

        -- Wait for respawn
        local newCharacter = player.CharacterAdded:Wait()
        local root = newCharacter:WaitForChild("HumanoidRootPart", 10)
        
        if not autoFarmActive then return end
        setControlsLocked(true) -- Re-apply lock to newly spawned character
        task.wait(0.5)

        -- 2. Teleport
        statusLabel.Text = "Status: Teleporting..."
        if root then
            root.CFrame = CFrame.new(teleportTarget)
        end

        -- 3. Farming Loop
        while autoFarmActive do
            -- 40-second timer
            for i = 40, 1, -1 do
                if not autoFarmActive then break end
                statusLabel.Text = "⏳ Loading... please wait (" .. i .. "s)"
                statusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
                task.wait(1)
            end

            if not autoFarmActive then break end

            -- Movement execution
            statusLabel.Text = "🚶 Moving Forward & Backward..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 230, 130)
            runVorUndZurueck()
        end

        if not autoFarmActive then
            stopAll()
        end
    end)
end)
