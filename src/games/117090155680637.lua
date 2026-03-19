--[[
    onzeHub - Rusty Rafts
    ID: 117090155680637
]]

--!nocheck
---@diagnostic disable: undefined-global

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)

    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function getChar() return LocalPlayer.Character end
    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function getHum()
        local c = getChar()
        return c and c:FindFirstChild("Humanoid")
    end

    -- =============================================
    -- [[ INFO ]]
    -- =============================================
    Tabs.Specific:AddSection("Rusty Rafts VIP")

    Tabs.Specific:AddParagraph({
        Title = "🚢 Rusty Rafts Premium",
        Content = "Sobrevive al océano infinito. Recolecta recursos, construye tu balsa, defiéndete de tiburones y otros jugadores."
    })

    -- =============================================
    -- [[ RECOLECCIÓN Y FARMING ]]
    -- =============================================
    Tabs.Specific:AddSection("⛏️ Farming y Recolección")

    -- Auto-recoger items flotantes
    Tabs.Specific:AddToggle("RR_AutoCollect", {
        Title = "Auto Recoger Objetos del Océano",
        Description = "Teletransporta los recursos flotantes del agua hacia ti automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.RR_AutoCollect = Value
            task.spawn(function()
                while _G.RR_AutoCollect do
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end

                        for _, obj in workspace:GetDescendants() do
                            if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Anchored == false then
                                local name = string.lower(obj.Name)
                                if string.find(name, "wood") or string.find(name, "scrap") 
                                    or string.find(name, "barrel") or string.find(name, "plank")
                                    or string.find(name, "metal") or string.find(name, "plastic")
                                    or string.find(name, "loot") or string.find(name, "crate")
                                    or string.find(name, "item") or string.find(name, "drop") then
                                    local dist = (hrp.Position - obj.Position).Magnitude
                                    if dist < 100 and dist > 3 then
                                        obj.CFrame = hrp.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    -- Auto pesca
    Tabs.Specific:AddToggle("RR_AutoFish", {
        Title = "Auto Pesca",
        Description = "Activa la caña automáticamente si la tienes equipada.",
        Default = false,
        Callback = function(Value)
            _G.RR_AutoFish = Value
            task.spawn(function()
                while _G.RR_AutoFish do
                    pcall(function()
                        local char = getChar()
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool and string.find(string.lower(tool.Name), "rod") then
                                tool:Activate()
                            end
                        end
                    end)
                    task.wait(2.5)
                end
            end)
        end
    })

    -- =============================================
    -- [[ COMBATE Y SUPERVIVENCIA ]]
    -- =============================================
    Tabs.Specific:AddSection("⚔️ Combate y Supervivencia")

    -- God Mode
    Tabs.Specific:AddToggle("RR_GodMode", {
        Title = "Modo Dios (Salud Infinita)",
        Description = "Los tiburones y jugadores no podrán matarte.",
        Default = false,
        Callback = function(Value)
            _G.RR_GodMode = Value
            task.spawn(function()
                while _G.RR_GodMode do
                    pcall(function()
                        local hum = getHum()
                        if hum then hum.Health = hum.MaxHealth end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    -- Velocidad
    Tabs.Specific:AddSlider("RR_Speed", {
        Title = "Velocidad de Movimiento",
        Description = "Muévete más rápido por tu balsa y el océano.",
        Default = 16,
        Min = 16,
        Max = 120,
        Rounding = 1,
        Callback = function(Value)
            pcall(function()
                local hum = getHum()
                if hum then hum.WalkSpeed = Value end
            end)
        end
    })

    -- Super Salto
    Tabs.Specific:AddSlider("RR_Jump", {
        Title = "Super Salto",
        Description = "Salta entre balsas enemigas fácilmente.",
        Default = 50,
        Min = 50,
        Max = 250,
        Rounding = 1,
        Callback = function(Value)
            pcall(function()
                local hum = getHum()
                if hum then
                    hum.JumpPower = Value
                    hum.UseJumpPower = true
                end
            end)
        end
    })

    -- =============================================
    -- [[ VISUALES ]]
    -- =============================================
    Tabs.Specific:AddSection("👁️ Visuales Premium")

    -- ESP Jugadores
    Tabs.Specific:AddToggle("RR_PlayerESP", {
        Title = "ESP Jugadores y Balsas",
        Description = "Ve a otros jugadores y sus balsas a través de la niebla y distancia.",
        Default = false,
        Callback = function(Value)
            _G.RR_PlayerESP = Value
            task.spawn(function()
                while _G.RR_PlayerESP do
                    pcall(function()
                        for _, p in Players:GetPlayers() do
                            if p ~= LocalPlayer and p.Character then
                                if not p.Character:FindFirstChild("onze_rr_esp") then
                                    local h = Instance.new("Highlight")
                                    h.Name = "onze_rr_esp"
                                    h.FillColor = Color3.fromRGB(0, 200, 255)
                                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    h.FillTransparency = 0.4
                                    h.Parent = p.Character
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end

                for _, p in Players:GetPlayers() do
                    if p.Character and p.Character:FindFirstChild("onze_rr_esp") then
                        p.Character:FindFirstChild("onze_rr_esp"):Destroy()
                    end
                end
            end)
        end
    })

    -- ESP Tiburones y peligros
    Tabs.Specific:AddToggle("RR_SharkESP", {
        Title = "ESP Tiburones / Peligros",
        Description = "Detecta tiburones, tormentas y peligros del océano.",
        Default = false,
        Callback = function(Value)
            _G.RR_SharkESP = Value
            task.spawn(function()
                local dangerKeywords = {"shark", "storm", "danger", "enemy", "piranha", "creature", "whale", "monster"}
                while _G.RR_SharkESP do
                    pcall(function()
                        for _, obj in workspace:GetDescendants() do
                            if (obj:IsA("Model") or obj:IsA("BasePart")) and not obj:FindFirstChild("onze_rr_danger") then
                                local name = string.lower(obj.Name)
                                for _, kw in dangerKeywords do
                                    if string.find(name, kw) then
                                        local h = Instance.new("Highlight")
                                        h.Name = "onze_rr_danger"
                                        h.FillColor = Color3.fromRGB(255, 30, 30)
                                        h.OutlineColor = Color3.fromRGB(255, 200, 0)
                                        h.FillTransparency = 0.3
                                        h.Parent = obj
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end

                for _, obj in workspace:GetDescendants() do
                    local esp = obj:FindFirstChild("onze_rr_danger")
                    if esp then esp:Destroy() end
                end
            end)
        end
    })

    -- FullBright
    Tabs.Specific:AddToggle("RR_FullBright", {
        Title = "FullBright (Sin niebla oceánica)",
        Description = "Quita la oscuridad del mar y la niebla para ver todo claro.",
        Default = false,
        Callback = function(Value)
            _G.RR_FullBright = Value
            local Lighting = game:GetService("Lighting")
            task.spawn(function()
                while _G.RR_FullBright do
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    task.wait(1)
                end
                Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                Lighting.FogEnd = 1000
            end)
        end
    })

    -- =============================================
    -- [[ MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("🕊️ Movimiento")

    -- Noclip
    Tabs.Specific:AddToggle("RR_Noclip", {
        Title = "Noclip (Nadar por paredes)",
        Description = "Atraviesa la balsa y objetos sólidos.",
        Default = false,
        Callback = function(Value)
            _G.RR_Noclip = Value
            task.spawn(function()
                local conn
                conn = game:GetService("RunService").Stepped:Connect(function()
                    if not _G.RR_Noclip then
                        conn:Disconnect()
                        return
                    end
                    pcall(function()
                        local char = getChar()
                        if char then
                            for _, part in char:GetDescendants() do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end)
            end)
        end
    })

    -- Fly
    Tabs.Specific:AddToggle("RR_Fly", {
        Title = "Volar (Fly Mode)",
        Description = "Vuela sobre el océano. W/S/A/D + E Subir / Q Bajar",
        Default = false,
        Callback = function(Value)
            _G.RR_Fly = Value
            pcall(function()
                local hrp = getHRP()
                local hum = getHum()
                if not hrp or not hum then return end

                if Value then
                    hum.PlatformStand = true

                    local bp = Instance.new("BodyPosition")
                    bp.Name     = "onze_rr_fly_bp"
                    bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bp.Position = hrp.Position
                    bp.Parent   = hrp

                    local bg = Instance.new("BodyGyro")
                    bg.Name      = "onze_rr_fly_bg"
                    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                    bg.CFrame    = hrp.CFrame
                    bg.Parent    = hrp

                    local uis = game:GetService("UserInputService")
                    task.spawn(function()
                        while _G.RR_Fly and hrp and hrp.Parent do
                            pcall(function()
                                local cam = workspace.CurrentCamera
                                local dir = Vector3.zero

                                if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                                if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                                if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                                if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                                if uis:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.yAxis end
                                if uis:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.yAxis end

                                if dir.Magnitude > 0 then
                                    bp.Position += dir.Unit * 50 * task.wait()
                                else
                                    task.wait(0.03)
                                end
                                bg.CFrame = cam.CFrame
                            end)
                        end
                    end)
                else
                    local bp = hrp:FindFirstChild("onze_rr_fly_bp")
                    local bg = hrp:FindFirstChild("onze_rr_fly_bg")
                    if bp then bp:Destroy() end
                    if bg then bg:Destroy() end
                    if hum then hum.PlatformStand = false end
                end
            end)
        end
    })

end

return Module
