-- Script de GUI Compacta para Móvil con Nombre RGB, Vuelo, Animación de Apagado y Animación de Entrada

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === CONFIGURACIÓN GENERAL ===
local GUI_NAME = "Samu Fly GUI" -- Tu nombre personalizado
local RGB_SPEED = 0.005 -- Velocidad del cambio de color RGB (menor = más lento)
local FLY_SPEED = 50 -- Velocidad de vuelo (ajusta este valor)

local TWEEN_INFO_GENERAL = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0) -- Info para animaciones generales
local TRASH_ANIM_DURATION = 0.5 -- Duración de la animación de la papelera y el script metiéndose

local LIGHT_ANIM_DURATION = 0.8 -- Duración de la animación de la luz
local LIGHT_BRIGHTNESS = 2 -- Brillo máximo del destello

-- === DIMENSIONES Y POSICIONES DE LA GUI PRINCIPAL ===
local expandedSize = UDim2.new(0.4, 0, 0.32, 0)
local expandedPosition = UDim2.new(0.3, 0, 0.25, 0) -- Posición final de la GUI

local minimizedSize = UDim2.new(0.5, 0, 0.05, 0)
local minimizedPosition = UDim2.new(0.25, 0, 0.95, 0)

-- === VARIABLES DE ESTADO ===
local isFlying = false
local flyToggleBtn = nil
local isDraggingFlyButton = false
local dragStartPos = Vector2.new(0,0)
local dragStartButtonPos = UDim2.new(0,0,0,0)

-- Almacenar las conexiones para limpiarlas al apagar
local connections = {}

-- === CREACIÓN DE LA GUI PRINCIPAL (Inicialmente invisible) ===
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
mainFrame.Visible = false -- ¡Ahora empieza invisible!

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- === BARRA DE TÍTULO ===
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

-- === BOTÓN MINIMIZAR ===
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

-- === CONTENIDO PRINCIPAL DE LA GUI ===
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 0.85, 0)
contentFrame.Position = UDim2.new(0, 0, 0.15, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame
contentFrame.ClipsDescendants = true

-- Botón de ejemplo "Pulsa aquí"
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
    print("El botón de ejemplo ha sido pulsado. Estado: " .. tostring(buttonState))
end)

-- *** BOTÓN "FREE FLY" EN LA GUI PRINCIPAL ***
local freeFlyActivatorButton = Instance.new("TextButton")
freeFlyActivatorButton.Name = "FreeFlyActivator"
freeFlyActivatorButton.Size = UDim2.new(0.8, 0, 0.28, 0)
freeFlyActivatorButton.Position = UDim2.new(0.1, 0, 0.38, 0)
freeFlyActivatorButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
freeFlyActivatorButton.Text = "Mostrar/Ocultar Free Fly"
freeFlyActivatorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
freeFlyActivatorButton.TextScaled = true
freeFlyActivatorButton.Font = Enum.Font.SourceSansBold
freeFlyActivatorButton.BorderSizePixel = 0
freeFlyActivatorButton.Parent = contentFrame

local freeFlyBtnCorner = Instance.new("UICorner")
freeFlyBtnCorner.CornerRadius = UDim.new(0, 6)
freeFlyBtnCorner.Parent = freeFlyActivatorButton

-- *** BOTÓN "APAGAR SCRIPT" ***
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

-- === BARRA MINIMIZADA ===
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

-- Botón para expandir (el "↕️" azul)
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

-- === FUNCIONES DE MINIMIZAR Y RESTAURAR GUI PRINCIPAL ===
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

-- === LÓGICA DE VUELO (INTEGRADA Y CONTROLADA POR BOTÓN) ===
local Humanoid = nil
local RootPart = nil

local function updateFlyStatusText()
    if flyToggleBtn then
        flyToggleBtn.Text = "Fly: " .. (isFlying and "ON" or "OFF")
        flyToggleBtn.BackgroundColor3 = isFlying and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end
end

local function toggleFly()
    if not LocalPlayer.Character then return end

    Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not RootPart then
        warn("No se pudo encontrar Humanoid o HumanoidRootPart para volar.")
        return
    end

    isFlying = not isFlying
    updateFlyStatusText()

    if isFlying then
        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        RootPart.Anchored = true
        print("Vuelo activado.")
    else
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        RootPart.Anchored = false
        RootPart.Velocity = Vector3.new(0,0,0)
        print("Vuelo desactivado.")
    end
end

-- === CREACIÓN Y LÓGICA DEL BOTÓN FLOTANTE DE VUELO ===
local function createFlyToggleButton()
    if flyToggleBtn then return end

    flyToggleBtn = Instance.new("TextButton")
    flyToggleBtn.Name = "FlyToggleButton"
    flyToggleBtn.Size = UDim2.new(0.12, 0, 0.08, 0)
    flyToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
    flyToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    flyToggleBtn.Text = "Fly: OFF"
    flyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyToggleBtn.TextScaled = true
    flyToggleBtn.Font = Enum.Font.SourceSansBold
    flyToggleBtn.BorderSizePixel = 0
    flyToggleBtn.Parent = PlayerGui

    local flyBtnCorner = Instance.new("UICorner")
    flyBtnCorner.CornerRadius = UDim.new(0, 8)
    flyBtnCorner.Parent = flyToggleBtn

    local dragConnection1 = nil
    local dragConnection2 = nil

    dragConnection1 = flyToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingFlyButton = true
            dragStartPos = UserInputService:GetMouseLocation()
            dragStartButtonPos = flyToggleBtn.Position
            
            dragConnection2 = UserInputService.InputChanged:Connect(function(input2)
                if isDraggingFlyButton and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                    local currentMousePos = UserInputService:GetMouseLocation()
                    local delta = currentMousePos - dragStartPos

                    local newPosX = dragStartButtonPos.X.Offset + delta.X
                    local newPosY = dragStartButtonPos.Y.Offset + delta.Y

                    newPosX = math.max(0, math.min(newPosX, PlayerGui.AbsoluteSize.X - flyToggleBtn.AbsoluteSize.X))
                    newPosY = math.max(0, math.min(newPosY, PlayerGui.AbsoluteSize.Y - flyToggleBtn.AbsoluteSize.Y))

                    flyToggleBtn.Position = UDim2.new(0, newPosX, 0, newPosY)
                end
            end)
            connections[#connections + 1] = dragConnection2
        end
    end)
    connections[#connections + 1] = dragConnection1

    local dragConnection3 = UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDraggingFlyButton then
            isDraggingFlyButton = false
        end
    end)
    connections[#connections + 1] = dragConnection3

    connections[#connections + 1] = flyToggleBtn.MouseButton1Click:Connect(toggleFly)
end

local function destroyFlyToggleButton()
    if flyToggleBtn then
        flyToggleBtn:Destroy()
        flyToggleBtn = nil
        isFlying = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            end
        end
        print("Botón de vuelo destruido y vuelo desactivado.")
    end
end

connections[#connections + 1] = freeFlyActivatorButton.MouseButton1Click:Connect(function()
    if flyToggleBtn then
        destroyFlyToggleButton()
    else
        createFlyToggleButton()
    end
end)


-- === LÓGICA DE MOVIMIENTO DE VUELO (WASD, Q, E) ===
local flyRenderSteppedConnection = RunService.RenderStepped:Connect(function()
    if isFlying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        local direction = Vector3.new(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + rootPart.CFrame.lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - rootPart.CFrame.lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - rootPart.CFrame.rightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + rootPart.CFrame.rightVector
        end

        local verticalSpeed = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            verticalSpeed = FLY_SPEED
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            verticalSpeed = -FLY_SPEED
        end

        if direction.Magnitude > 0 or verticalSpeed ~= 0 then
            local currentVerticalVelocity = rootPart.Velocity.Y
            if verticalSpeed == 0 then
                verticalSpeed = currentVerticalVelocity
            end
            rootPart.Velocity = (direction.Unit * FLY_SPEED) + Vector3.new(0, verticalSpeed, 0)
        else
            rootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)
connections[#connections + 1] = flyRenderSteppedConnection


-- === EFECTO RGB PARA EL NOMBRE DE LA GUI ===
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

-- === ANIMACIÓN Y FUNCIÓN DE APAGADO Y LIMPIEZA DEL SCRIPT ===
local function shutdownScript()
    -- 1. Desactivar el vuelo y limpiar si está activo
    if isFlying then
        toggleFly()
    end
    -- 2. Destruir el botón flotante de vuelo si existe
    destroyFlyToggleButton()

    -- Bloquear el botón de apagado para evitar pulsaciones múltiples
    shutdownButton.Active = false
    shutdownButton.Text = "Apagando..."
    mainFrame.Active = false -- Desactivar interacción con la GUI

    -- Crear la papelera
    local trashCan = Instance.new("ImageLabel")
    trashCan.Name = "TrashCanAnim"
    trashCan.Size = UDim2.new(0.3, 0, 0.4, 0)
    trashCan.Position = UDim2.new(-trashCan.Size.X.Scale, 0, 0.3, 0) -- Inicia completamente fuera
    trashCan.BackgroundTransparency = 1
    trashCan.Image = "rbxassetid://13217277873" -- ID de una imagen de papelera (Roblox default si existe, o buscar una)
    trashCan.ScaleType = Enum.ScaleType.Fit
    trashCan.ZIndex = 10
    trashCan.Parent = PlayerGui

    -- Animar la papelera para que entre en la pantalla
    local trashTween = TweenService:Create(trashCan, TweenInfo.new(TRASH_ANIM_DURATION / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.05, 0, 0.3, 0)})
    trashTween:Play()
    trashTween.Completed:Wait()

    -- Animar la GUI para que se mueva hacia la papelera
    -- Calcular la posición objetivo de la GUI para que entre en la papelera
    local trashCanAbsPos = trashCan.AbsolutePosition
    local trashCanAbsSize = trashCan.AbsoluteSize
    
    local targetXOffset = trashCanAbsPos.X + trashCanAbsSize.X / 2 - mainFrame.AbsoluteSize.X / 2
    local targetYOffset = trashCanAbsPos.Y + trashCanAbsSize.Y / 2 - mainFrame.AbsoluteSize.Y / 2

    local guiToTrashTween = TweenService:Create(mainFrame, TweenInfo.new(TRASH_ANIM_DURATION / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, targetXOffset, 0, targetYOffset),
        Size = UDim2.new(0.05, 0, 0.05, 0), -- Hacerla pequeña
        BackgroundTransparency = 1,
        Transparency = 1
    })
    guiToTrashTween:Play()
    guiToTrashTween.Completed:Wait()

    -- Limpieza final del script
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

    print("Script 'Samu Fly GUI' apagado y eliminado con animación. ¡Hasta la próxima!")
end

-- === ANIMACIÓN DE ENTRADA AL EJECUTAR EL SCRIPT ===
local function animateEntrance()
    mainFrame.Visible = false -- Asegurarse de que esté invisible al principio
    local originalPos = expandedPosition
    
    -- Crear la luz amarilla
    local brightLight = Instance.new("Frame")
    brightLight.Name = "EntranceLight"
    brightLight.Size = UDim2.new(1, 0, 0.1, 0) -- Barra de luz que baja
    brightLight.Position = UDim2.new(0, 0, -0.1, 0) -- Empieza fuera de la pantalla por arriba
    brightLight.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Amarillo
    brightLight.BackgroundTransparency = 1 -- Empieza transparente
    brightLight.BorderSizePixel = 0
    brightLight.ZIndex = 9 -- Justo debajo de la GUI
    brightLight.Parent = PlayerGui

    -- Animar la luz bajando y volviéndose visible
    local lightTween1 = TweenService:Create(brightLight, TweenInfo.new(LIGHT_ANIM_DURATION * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = expandedPosition, -- Baja hasta la posición de la GUI
        BackgroundTransparency = 0.5 -- Se vuelve semitransparente
    })
    lightTween1:Play()
    lightTween1.Completed:Wait()

    -- Destello fuerte (se hace más brillante y luego se desvanece rápido)
    local lightTween2 = TweenService:Create(brightLight, TweenInfo.new(LIGHT_ANIM_DURATION * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0), -- Se expande para un destello
        BackgroundTransparency = 0, -- Totalmente opaca para el brillo máximo
        BackgroundColor3 = Color3.fromRGB(255, 255, 100) -- Un amarillo más claro para el destello
    })
    lightTween2:Play()
    
    -- Hacer visible el script principal
    mainFrame.Visible = true

    lightTween2.Completed:Wait()

    -- Destello se desvanece
    local lightTween3 = TweenService:Create(brightLight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1, -- Se vuelve transparente
        Size = UDim2.new(1,0,0,0) -- Se encoge
    })
    lightTween3:Play()
    lightTween3.Completed:Wait()

    brightLight:Destroy() -- Eliminar la luz

    print("Animación de entrada completada. GUI lista.")
end

-- === CONEXIONES INICIALES AL CARGAR EL SCRIPT ===
connections[#connections + 1] = minimizeButton.MouseButton1Click:Connect(minimizeGUI)
connections[#connections + 1] = restoreButton.MouseButton1Click:Connect(restoreGUI)
connections[#connections + 1] = shutdownButton.MouseButton1Click:Connect(shutdownScript)

-- Llamar a la animación de entrada al principio del script
animateEntrance()

print("GUI 'Samu Fly GUI' cargada con animaciones de entrada y apagado.")
