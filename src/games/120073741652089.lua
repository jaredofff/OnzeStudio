--[[
    onzeHub - Hunting Season: Boulder Creek
    ID: 120073741652089
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Estado del Cazador")

    Tabs.Specific:AddParagraph({
        Title = "Hunting Season VIP v2.0",
        Content = "Script avanzado para caza automática y visualización de presas."
    })

    -- Servicos & Helpers
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    
    local function getChar()
        return LocalPlayer.Character
    end

    local function getHRP()
        return getChar() and getChar():FindFirstChild("HumanoidRootPart")
    end

    -- =============================================
    -- [[ SECCIÓN: VISUALES (ESP) ]]
    -- =============================================
    Tabs.Specific:AddSection("Visuales (ESP)")

    Tabs.Specific:AddToggle("HS_AnimalESP", {
        Title = "ESP Animales",
        Description = "Muestra la ubicación y distancia de las presas.",
        Default = false,
        Callback = function(Value)
            _G.HS_AnimalESP = Value
            if not Value then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "AnimalHighlight" or v.Name == "AnimalESPLabel" then
                        v:Destroy()
                    end
                end
            end
        end
    })

    Tabs.Specific:AddToggle("HS_PlayerESP", {
        Title = "ESP Jugadores (Rivales)",
        Description = "Muestra a otros cazadores en el mapa.",
        Default = false,
        Callback = function(Value)
            _G.HS_PlayerESP = Value
            if not Value then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "PlayerHighlight" then
                        v:Destroy()
                    end
                end
            end
        end
    })

    task.spawn(function()
        while true do
            if _G.HS_AnimalESP or _G.HS_PlayerESP then
                pcall(function()
                    local hrp = getHRP()
                    -- Procesar Workspace
                    for _, v in pairs(workspace:GetChildren()) do
                        local isPlayer = Players:GetPlayerFromCharacter(v)
                        
                        -- Lógica Animales
                        if _G.HS_AnimalESP and v:FindFirstChild("Humanoid") and v ~= getChar() and not isPlayer then
                            if not v:FindFirstChild("AnimalHighlight") then
                                local h = Instance.new("Highlight")
                                h.Name = "AnimalHighlight"
                                h.FillColor = Color3.fromRGB(255, 100, 100)
                                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                h.Parent = v
                            end
                            
                            -- Etiqueta de Distancia
                            if hrp and v:FindFirstChild("PrimaryPart") then
                                local dist = math.floor((hrp.Position - v.PrimaryPart.Position).Magnitude)
                                local label = v:FindFirstChild("AnimalESPLabel") or Instance.new("BillboardGui")
                                label.Name = "AnimalESPLabel"
                                label.AlwaysOnTop = true
                                label.Size = UDim2.fromOffset(100, 50)
                                label.Adornee = v.PrimaryPart
                                label.Parent = v
                                
                                local text = label:FindFirstChild("Text") or Instance.new("TextLabel")
                                text.Name = "Text"
                                text.BackgroundTransparency = 1
                                text.Size = UDim2.fromScale(1, 1)
                                text.Text = string.format("%s\n[%dm]", v.Name, dist)
                                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                                text.TextStrokeTransparency = 0
                                text.Font = Enum.Font.Code
                                text.TextSize = 14
                                text.Parent = label
                            end
                        end

                        -- Lógica Jugadores
                        if _G.HS_PlayerESP and isPlayer and v ~= getChar() then
                            if not v:FindFirstChild("PlayerHighlight") then
                                local h = Instance.new("Highlight")
                                h.Name = "PlayerHighlight"
                                h.FillColor = Color3.fromRGB(100, 255, 100)
                                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                h.Parent = v
                            end
                        end
                    end
                end)
            end
            task.wait(1.5)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: COMBATE & ARMAS ]]
    -- =============================================
    Tabs.Specific:AddSection("Mejoras de Armas")

    Tabs.Specific:AddToggle("HS_NoRecoil", {
        Title = "Sin Retroceso",
        Default = false,
        Callback = function(v) _G.HS_NoRecoil = v end
    })

    Tabs.Specific:AddToggle("HS_InfAmmo", {
        Title = "Munición Infinita",
        Default = false,
        Callback = function(v) _G.HS_InfAmmo = v end
    })

    -- Hook simple para armas (puede variar según el sistema del juego)
    RunService.RenderStepped:Connect(function()
        if _G.HS_NoRecoil or _G.HS_InfAmmo then
            pcall(function()
                local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
                if tool and (tool:FindFirstChild("Configuration") or tool:FindFirstChild("Values")) then
                    -- Ajustar valores si existen
                    local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Values")
                    if _G.HS_NoRecoil and config:FindFirstChild("Recoil") then
                        config.Recoil.Value = 0
                    end
                    if _G.HS_InfAmmo and config:FindFirstChild("Ammo") then
                        config.Ammo.Value = 999
                    end
                end
            end)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: AUTO FARM ]]
    -- =============================================
    Tabs.Specific:AddSection("Auto Caza")

    Tabs.Specific:AddToggle("HS_AutoFarm", {
        Title = "Auto Farm Animales",
        Description = "Te transporta al animal más cercano continuamente.",
        Default = false,
        Callback = function(Value) _G.HS_AutoFarm = Value end
    })

    task.spawn(function()
        while true do
            if _G.HS_AutoFarm then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    local target = nil
                    local minDist = 1000
                    
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v ~= getChar() and not Players:GetPlayerFromCharacter(v) then
                            local dist = (hrp.Position - v.PrimaryPart.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                target = v
                            end
                        end
                    end
                    
                    if target and _G.HS_AutoFarm then
                        hrp.CFrame = target.PrimaryPart.CFrame * CFrame.new(0, 10, 0) -- Teletransportar arriba para evitar ataques
                        task.wait(0.5)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento VIP")

    Tabs.Specific:AddToggle("HS_InfJump", {
        Title = "Salto Infinito",
        Default = false,
        Callback = function(v)
            _G.HS_InfJump = v
        end
    })

    UserInputService.JumpRequest:Connect(function()
        if _G.HS_InfJump then
            local hum = getChar() and getChar():FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState("Jumping")
            end
        end
    end)

    Tabs.Specific:AddToggle("HS_Noclip", {
        Title = "Atravesar Paredes",
        Default = false,
        Callback = function(v)
            _G.HS_Noclip = v
        end
    })

    RunService.Stepped:Connect(function()
        if _G.HS_Noclip and getChar() then
            for _, v in pairs(getChar():GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    Tabs.Specific:AddSlider("HS_Speed", {
        Title = "Velocidad de Movimiento",
        Default = 16,
        Min = 16,
        Max = 300,
        Rounding = 1,
        Callback = function(v)
            pcall(function() getChar().Humanoid.WalkSpeed = v end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: MISC ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades")

    Tabs.Specific:AddButton({
        Title = "Eliminar Follaje/Arbustos",
        Description = "Mejora la visibilidad eliminando vegetación estorbosa.",
        Callback = function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (string.find(v.Name:lower(), "bush") or string.find(v.Name:lower(), "tree")) then
                    v:Destroy()
                end
            end
            Fluent:Notify({Title = "onzeHub", Content = "Vegetación eliminada.", Duration = 3})
        end
    })

end

return Module
