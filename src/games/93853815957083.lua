--[[
    🚀 onzeHub - AFILADO: PROFESIONAL (Senior Module)
    Developer: Antigravity (Senior Luau Scripting)
    Optimization: O(n) Player Iteration, Hex-Color ESP, Connection Management
]]

local GameModule = {}

-- [[ LIBRERÍAS Y SERVICIOS ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- [[ VARIABLES DE ESTADO ESTÁTICO ]]
local states = {
    KillAura = false,
    Hitbox = false,
    ESP = false,
    Speed = false,
    InfJump = false
}

-- [[ REGISTRO DE CONEXIONES (CLEANUP SYSTEM) ]]
local connections = {
    KillAura = nil,
    Hitbox = nil,
    ESP = {},
    Speed = nil,
    InfJump = nil
}

-- [[ FUNCIONES DE UTILIDAD (PROFESIONAL) ]]
local function GetCharacter(player)
    return player.Character or player.CharacterAdded:Wait()
end

local function IsAlive(model)
    if not model then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- [[ SISTEMA DE LIMPIEZA DE ESP ]]
local function ClearESP()
    for _, player in Players:GetPlayers() do
        if player.Character then
            local hl = player.Character:FindFirstChild("oH_Premium_ESP")
            if hl then hl:Destroy() end
        end
    end
    for i, conn in connections.ESP do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        connections.ESP[i] = nil
    end
end

-- [[ LÓGICA PRINCIPAL DEL MÓDULO ]]
function GameModule.Load(Tabs, Window, Fluent, Options)
    local MainSection = Tabs.Specific:AddSection("⚔️ Combate Profesional")
    local ESPSection = Tabs.Specific:AddSection("👁️ Visuales Elite")
    local MovementSection = Tabs.Specific:AddSection("🏃 Movimiento Avanzado")

    ---------------------------------------------------------------------------
    -- [[ KILL AURA (OPTIMIZADO) ]]
    ---------------------------------------------------------------------------
    MainSection:AddToggle("Killaura", {
        Title = "KillAura Elite",
        Description = "Ataque inteligente en área 360° con validación de salud.",
        Default = false,
        Callback = function(state)
            states.KillAura = state
            
            -- Desconectar si existe una previa
            if connections.KillAura then 
                connections.KillAura:Disconnect() 
                connections.KillAura = nil
            end

            if state then
                connections.KillAura = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    if not IsAlive(char) then return end
                    
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local weapon = char:FindFirstChildOfClass("Tool")
                    if not (hrp and weapon and weapon:FindFirstChild("Handle")) then return end

                    -- Iteración eficiente por jugadores (Evita GetDescendants)
                    for _, player in Players:GetPlayers() do
                        if player ~= LocalPlayer and player.Character then
                            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if targetHrp and IsAlive(player.Character) then
                                local distance = (hrp.Position - targetHrp.Position).Magnitude
                                if distance <= 20 then
                                    -- Protocolo de daño (FireTouchInterest es el estándar compatible con mayoría de exploits)
                                    if firetouchinterest then
                                        firetouchinterest(weapon.Handle, targetHrp, 0)
                                        task.wait() -- Debounce de seguridad
                                        firetouchinterest(weapon.Handle, targetHrp, 1)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    })

    ---------------------------------------------------------------------------
    -- [[ HITBOX EXPANDER (ROBUSTO) ]]
    ---------------------------------------------------------------------------
    MainSection:AddToggle("Hitbox", {
        Title = "Expandir Hitboxes",
        Description = "Aumenta el volumen de impacto de enemigos cercanos.",
        Default = false,
        Callback = function(state)
            states.Hitbox = state
            
            if connections.Hitbox then 
                connections.Hitbox:Disconnect()
                connections.Hitbox = nil
            end

            if state then
                connections.Hitbox = RunService.Heartbeat:Connect(function()
                    for _, player in Players:GetPlayers() do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Aplicar escala premium
                                hrp.Size = Vector3.new(20, 20, 20)
                                hrp.Transparency = 0.8
                                hrp.CanCollide = false
                            end
                        end
                    end
                end)
            else
                -- Limpieza inmediata: Restaurar tamaños originales
                for _, player in Players:GetPlayers() do
                    if player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.Transparency = 0
                            hrp.CanCollide = true
                        end
                    end
                end
            end
        end
    })

    ---------------------------------------------------------------------------
    -- [[ ESP ELITE (MODERNO) ]]
    ---------------------------------------------------------------------------
    local function ApplyESP(player)
        if player == LocalPlayer then return end
        
        local function CreateHighlight(character)
            if not states.ESP then return end
            if character:FindFirstChild("oH_Premium_ESP") then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "oH_Premium_ESP"
            highlight.FillColor = Color3.fromRGB(0, 255, 127) -- Esmeralda Premium
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = character
        end

        if player.Character then CreateHighlight(player.Character) end
        connections.ESP[player.Name] = player.CharacterAdded:Connect(CreateHighlight)
    end

    ESPSection:AddToggle("ESP", {
        Title = "ESP Pro (Highlights)",
        Description = "Visión de rayos X alta fidelidad con persistencia tras muerte.",
        Default = false,
        Callback = function(state)
            states.ESP = state
            if state then
                for _, player in Players:GetPlayers() do ApplyESP(player) end
                table.insert(connections.ESP, Players.PlayerAdded:Connect(ApplyESP))
            else
                ClearESP()
            end
        end
    })

    ---------------------------------------------------------------------------
    -- [[ VELOCIDAD CFRAME (LOW DETECTION) ]]
    ---------------------------------------------------------------------------
    MovementSection:AddToggle("SpeedMode", {
        Title = "CFrame Speed",
        Description = "Sprint asistido mediante manipulación de fotogramas.",
        Default = false,
        Callback = function(state)
            states.Speed = state
            if connections.Speed then
                connections.Speed:Disconnect()
                connections.Speed = nil
            end

            if state then
                connections.Speed = RunService.Heartbeat:Connect(function(deltaTime)
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                        -- Cálculo de desplazamiento basado en deltaTime para estabilidad
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (0.8 * 60 * deltaTime))
                    end
                end)
            end
        end
    })

    ---------------------------------------------------------------------------
    -- [[ INFINITE JUMP (CLEAN) ]]
    ---------------------------------------------------------------------------
    MovementSection:AddToggle("InfJump", {
        Title = "Saltos Infinitos",
        Description = "Permite saltar en el aire eliminando la gravedad.",
        Default = false,
        Callback = function(state)
            states.InfJump = state
            if connections.InfJump then
                connections.InfJump:Disconnect()
                connections.InfJump = nil
            end

            if state then
                connections.InfJump = UserInputService.JumpRequest:Connect(function()
                    if states.InfJump then
                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        end
    })

    -- Notificación de Bienvenida Profesional
    Fluent:Notify({
        Title = "onzeHub Premium",
        Content = "Módulo AFILADO v2.0 (Optimizado) cargado correctamente.",
        Duration = 6
    })
end

return GameModule
