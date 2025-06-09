local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GUI_NAME = "Samu Fly GUI"
local RGB_SPEED = 0.005
local FLY_SPEED_VALUE = 50
local MAX_FLY_SPEED = 100

local TWEEN_INFO_GENERAL = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local TRASH_ANIM_DURATION = 0.5

local LIGHT_ANIM_DURATION = 0.8
local LIGHT_BRIGHTNESS = 2

local expandedSize = UDim2.new(0.4, 0, 0.32, 0)
local expandedPosition = UDim2.new(0.3, 0, 0.25, 0)

local minimizedSize = UDim2.new(0.5, 0, 0.05, 0)
local minimizedPosition = UDim2.new(0.25, 0, 0.95, 0)

local isFlyActive = false
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flySpeedCurrent = 0
local lastFlyControl = {f = 0, b = 0, l = 0, r = 0}

local connections = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SamuFlyGUIMain"
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = expandedSize
mainFrame.Position = expandedPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0.15, 0)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = GUI_NAME
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0.1, 0, 0.8, 0)
minimizeButton.Position = UDim2.new(0.88, 0, 0.1, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeButton

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 0.85, 0)
contentFrame.Position = UDim2.new(0, 0, 0.15, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame
contentFrame.ClipsDescendants = true

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.8, 0, 0.28, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0.05, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.Text = "Pulsa aquí (Ejemplo)"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.BorderSizePixel = 0
toggleButton.Parent = contentFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

local buttonState = false
connections[#connections + 1] = toggleButton.MouseButton1Click:Connect(function()
    buttonState = not buttonState
    if buttonState then
        toggleButton.Text = "¡Activado!"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        toggleButton.Text = "¡Desactivado!"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Name = "ToggleFlyButton"
flyToggleBtn.Size = UDim2.new(0.8, 0, 0.28, 0)
flyToggleBtn.Position = UDim2.new(0.1, 0, 0.38, 0)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
flyToggleBtn.Text = "Vuelo: OFF"
flyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyToggleBtn.TextScaled = true
flyToggleBtn.Font = Enum.Font.SourceSansBold
flyToggleBtn.BorderSizePixel = 0
flyToggleBtn.Parent = contentFrame

local flyBtnCorner = Instance.new("UICorner")
flyBtnCorner.CornerRadius = UDim.new(0, 6)
flyBtnCorner.Parent = flyToggleBtn

local shutdownButton = Instance.new("TextButton")
shutdownButton.Name = "ShutdownButton"
shutdownButton.Size = UDim2.new(0.8, 0, 0.28, 0)
shutdownButton.Position = UDim2.new(0.1, 0, 0.71, 0)
shutdownButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
shutdownButton.Text = "Apagar Script"
shutdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shutdownButton.TextScaled = true
shutdownButton.Font = Enum.Font.SourceSansBold
shutdownButton.BorderSizePixel = 0
shutdownButton.Parent = contentFrame

local shutdownBtnCorner = Instance.new("UICorner")
shutdownBtnCorner.CornerRadius = UDim.new(0, 6)
shutdownBtnCorner.Parent = shutdownButton

local minimizedBar = Instance.new("Frame")
minimizedBar.Name = "MinimizedBar"
minimizedBar.Size = UDim2.new(1, 0, 1, 0)
minimizedBar.Position = UDim2.new(0, 0, 0, 0)
minimizedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizedBar.BorderSizePixel = 0
minimizedBar.Parent = mainFrame
minimizedBar.Visible = false

local minBarCorner = Instance.new("UICorner")
minBarCorner.CornerRadius = UDim.new(0, 8)
minBarCorner.Parent = minimizedBar

local minBarLabel = Instance.new("TextLabel")
minBarLabel.Name = "MinBarLabel"
minBarLabel.Size = UDim2.new(0.8, 0, 1, 0)
minBarLabel.Position = UDim2.new(0, 0, 0, 0)
minBarLabel.BackgroundTransparency = 1
minBarLabel.Text = GUI_NAME
minBarLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
minBarLabel.TextScaled = true
minBarLabel.Font = Enum.Font.SourceSansBold
minBarLabel.TextXAlignment = Enum.TextXAlignment.Left
minBarLabel.Parent = minimizedBar

local restoreButton = Instance.new("TextButton")
restoreButton.Name = "RestoreButton"
restoreButton.Size = UDim2.new(0.2, 0, 1, 0)
restoreButton.Position = UDim2.new(0.8, 0, 0, 0)
restoreButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
restoreButton.Text = "↕️"
restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreButton.TextScaled = true
restoreButton.Font = Enum.Font.SourceSansBold
restoreButton.BorderSizePixel = 0
restoreButton.Parent = minimizedBar

local function minimizeGUI()
    local goal = { Size = minimizedSize, Position = minimizedPosition }
    local tween = TweenService:Create(mainFrame, TWEEN_INFO_GENERAL, goal)
    tween:Play()

    contentFrame.Visible = false
    titleBar.Visible = false
    minimizedBar.Visible = true
end

local function restoreGUI()
    local goal = { Size = expandedSize, Position = expandedPosition }
    local tween = TweenService:Create(mainFrame, TWEEN_INFO_GENERAL, goal)
    tween:Play()

    tween.Completed:Wait() 
    contentFrame.Visible = true
    titleBar.Visible = true
    minimizedBar.Visible = false
end

local function enableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if not hum or not rootPart then return end

    isFlyActive = true
    flyToggleBtn.Text = "Vuelo: ON"
    flyToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)

    char.Animate.Disabled = true
    for i,v in next, hum:GetPlayingAnimationTracks() do
        v:AdjustSpeed(0)
    end

    hum.PlatformStand = true

    local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if upperTorso then
        flyBodyGyro = Instance.new("BodyGyro", upperTorso)
        flyBodyGyro.P = 9e4
        flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBodyGyro.CFrame = upperTorso.CFrame

        flyBodyVelocity = Instance.new("BodyVelocity", upperTorso)
        flyBodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
        flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    else
        rootPart.Anchored = true
    end
end

local function disableFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    if not hum or not rootPart then return end

    isFlyActive = false
    flyToggleBtn.Text = "Vuelo: OFF"
    flyToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
    hum:ChangeState(Enum.HumanoidStateType.Running)

    char.Animate.Disabled = false
    for i,v in next, hum:GetPlayingAnimationTracks() do
        v:AdjustSpeed(1)
    end

    hum.PlatformStand = false

    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    
    rootPart.Velocity = Vector3.new(0,0,0)
end

connections[#connections + 1] = LocalPlayer.CharacterAdded:Connect(function(char)
    if isFlyActive then
        disableFly()
    end
end)

connections[#connections + 1] = flyToggleBtn.MouseButton1Click:Connect(function()
    if isFlyActive then
        disableFly()
    else
        enableFly()
    end
end)

local flyRenderSteppedConnection = RunService.RenderStepped:Connect(function()
    if isFlyActive and LocalPlayer.Character then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

        if not hum or not rootPart or not upperTorso or not flyBodyGyro or not flyBodyVelocity then return end

        local ctrl = {f = 0, b = 0, l = 0, r = 0}

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then ctrl.f = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then ctrl.b = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then ctrl.l = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then ctrl.r = 1 end

        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            flySpeedCurrent = math.min(MAX_FLY_SPEED, flySpeedCurrent + 0.5 + (flySpeedCurrent / FLY_SPEED_VALUE))
            lastFlyControl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        elseif flySpeedCurrent ~= 0 then
            flySpeedCurrent = math.max(0, flySpeedCurrent - 1)
        end

        local currentCameraCFrame = game.Workspace.CurrentCamera.CFrame
        local targetVelocity = Vector3.new(0,0,0)

        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
            targetVelocity = ((currentCameraCFrame.lookVector * (ctrl.f + ctrl.b)) +
                             ((currentCameraCFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0)).p - currentCameraCFrame.p)) * flySpeedCurrent
        elseif flySpeedCurrent ~= 0 then
            targetVelocity = ((currentCameraCFrame.lookVector * (lastFlyControl.f + lastFlyControl.b)) +
                             ((currentCameraCFrame * CFrame.new(lastFlyControl.l + lastFlyControl.r, (lastFlyControl.f + lastFlyControl.b) * 0.2, 0)).p - currentCameraCFrame.p)) * flySpeedCurrent
        end

        local verticalSpeedInput = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            verticalSpeedInput = FLY_SPEED_VALUE
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            verticalSpeedInput = -FLY_SPEED_VALUE
        end

        flyBodyVelocity.Velocity = targetVelocity + Vector3.new(0, verticalSpeedInput, 0)
        flyBodyGyro.CFrame = currentCameraCFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * flySpeedCurrent / MAX_FLY_SPEED), 0, 0)
    end
end)
connections[#connections + 1] = flyRenderSteppedConnection

local hue = 0
local rgbRenderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
    hue = hue + (dt * RGB_SPEED)
    if hue > 1 then
        hue = hue - 1
    end
    local rgbColor = Color3.fromHSV(hue, 1, 1)

    if titleLabel then
        titleLabel.TextColor3 = rgbColor
    end
    if minBarLabel then
        minBarLabel.TextColor3 = rgbColor
    end
end)
connections[#connections + 1] = rgbRenderSteppedConnection

local function shutdownScript()
    if isFlyActive then
        disableFly()
    end

    shutdownButton.Active = false
    shutdownButton.Text = "Apagando..."
    mainFrame.Active = false
    mainFrame.Draggable = false

    local trashCan = Instance.new("ImageLabel")
    trashCan.Name = "TrashCanAnim"
    trashCan.Size = UDim2.new(0.3, 0, 0.4, 0)
    trashCan.Position = UDim2.new(-trashCan.Size.X.Scale, 0, 0.3, 0)
    trashCan.BackgroundTransparency = 1
    trashCan.Image = "rbxassetid://13217277873"
    trashCan.ScaleType = Enum.ScaleType.Fit
    trashCan.ZIndex = 10
    trashCan.Parent = PlayerGui

    local trashTween = TweenService:Create(trashCan, TweenInfo.new(TRASH_ANIM_DURATION / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.05, 0, 0.3, 0)})
    trashTween:Play()
    trashTween.Completed:Wait()

    local trashCanAbsPos = trashCan.AbsolutePosition
    local trashCanAbsSize = trashCan.AbsoluteSize
    
    local targetXOffset = trashCanAbsPos.X + trashCanAbsSize.X / 2 - mainFrame.AbsoluteSize.X / 2
    local targetYOffset = trashCanAbsPos.Y + trashCanAbsSize.Y / 2 - mainFrame.AbsoluteSize.Y / 2

    local guiToTrashTween = TweenService:Create(mainFrame, TweenInfo.new(TRASH_ANIM_DURATION / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, targetXOffset, 0, targetYOffset),
        Size = UDim2.new(0.05, 0, 0.05, 0),
        BackgroundTransparency = 1,
        Transparency = 1
    })
    guiToTrashTween:Play()
    guiToTrashTween.Completed:Wait()

    trashCan:Destroy()

    for _, conn in ipairs(connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    connections = {}

    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end

local function animateEntrance()
    mainFrame.Visible = false
    
    local brightLight = Instance.new("Frame")
    brightLight.Name = "EntranceLight"
    brightLight.Size = UDim2.new(1, 0, 0.1, 0)
    brightLight.Position = UDim2.new(0, 0, -0.1, 0)
    brightLight.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    brightLight.BackgroundTransparency = 1
    brightLight.BorderSizePixel = 0
    brightLight.ZIndex = 9
    brightLight.Parent = PlayerGui

    local lightTween1 = TweenService:Create(brightLight, TweenInfo.new(LIGHT_ANIM_DURATION * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = expandedPosition,
        BackgroundTransparency = 0.5
    })
    lightTween1:Play()
    lightTween1.Completed:Wait()

    local lightTween2 = TweenService:Create(brightLight, TweenInfo.new(LIGHT_ANIM_DURATION * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 100)
    })
    lightTween2:Play()
    
    mainFrame.Visible = true

    lightTween2.Completed:Wait()

    local lightTween3 = TweenService:Create(brightLight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,0)
    })
    lightTween3:Play()
    lightTween3.Completed:Wait()

    brightLight:Destroy()
end

connections[#connections + 1] = minimizeButton.MouseButton1Click:Connect(minimizeGUI)
connections[#connections + 1] = restoreButton.MouseButton1Click:Connect(restoreGUI)
connections[#connections + 1] = shutdownButton.MouseButton1Click:Connect(shutdownScript)

animateEntrance()
