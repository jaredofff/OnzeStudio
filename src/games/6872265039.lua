--[[
    onzeHub - Bedwars
    ID: 6872265039
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)

    -- =============================================
    -- [[ SECCIÓN: INFORMACIÓN ]]
    -- =============================================
    Tabs.Specific:AddSection("Información")

    Tabs.Specific:AddParagraph({
        Title = "Bedwars",
        Content = "Script de onzeHub cargado para Bedwars. Usa las funciones con precaución para evitar detección. ¡Destruye las camas enemigas y protege la tuya!"
    })

    -- Helpers
    local Players       = game:GetService("Players")
    local RunService    = game:GetService("RunService")
    local LocalPlayer   = Players.LocalPlayer

    local function getChar()
        return LocalPlayer.Character
    end

    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function getHum()
        local c = getChar()
        return c and c:FindFirstChild("Humanoid")
    end

    -- =============================================
    -- [[ SECCIÓN: COMBATE ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate")

    -- Kill Aura
    Tabs.Specific:AddToggle("BW_KillAura", {
        Title = "Kill Aura",
        Description = "Ataca automáticamente a los jugadores enemigos cercanos.",
        Default = false,
        Callback = function(Value)
            _G.BW_KillAura = Value
            task.spawn(function()
                while _G.BW_KillAura do
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end

                        local closest = nil
                        local minDist = 12 -- rango en studs

                        for _, p in Players:GetPlayers() do
                            if p ~= LocalPlayer and p.Character then
                                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                                local tHum = p.Character:FindFirstChild("Humanoid")
                                if tHRP and tHum and tHum.Health > 0 then
                                    local dist = (hrp.Position - tHRP.Position).Magnitude
                                    if dist < minDist then
                                        minDist = dist
                                        closest = p
                                    end
                                end
                            end
                        end

                        if closest and closest.Character then
                            local tHRP = closest.Character:FindFirstChild("HumanoidRootPart")
                            if tHRP then
                                -- Simular click usando VirtualInputManager
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end)
                    task.wait(0.15)
                end
            end)
        end
    })

    -- Anti-Knockback
    Tabs.Specific:AddToggle("BW_AntiKB", {
        Title = "Anti-Knockback",
        Description = "Reduce enormemente el retroceso al recibir golpes.",
        Default = false,
        Callback = function(Value)
            _G.BW_AntiKB = Value
            task.spawn(function()
                while _G.BW_AntiKB do
                    pcall(function()
                        local hrp = getHRP()
                        if hrp and hrp.AssemblyLinearVelocity.Magnitude > 30 then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    })

    -- Reach Extendido
    Tabs.Specific:AddSlider("BW_Reach", {
        Title = "Alcance de Ataque",
        Description = "Extiende el rango de combate cuerpo a cuerpo.",
        Default = 8,
        Min = 6,
        Max = 20,
        Rounding = 1,
        Callback = function(Value)
            _G.BW_ReachValue = Value
        end
    })

    -- =============================================
    -- [[ SECCIÓN: VISUALES (ESP) ]]
    -- =============================================
    Tabs.Specific:AddSection("Visuales (ESP)")

    -- ESP Jugadores
    Tabs.Specific:AddToggle("BW_PlayerESP", {
        Title = "ESP Jugadores",
        Description = "Muestra a todos los jugadores a través de las paredes.",
        Default = false,
        Callback = function(Value)
            _G.BW_PlayerESP = Value
            task.spawn(function()
                while _G.BW_PlayerESP do
                    pcall(function()
                        for _, p in Players:GetPlayers() do
                            if p ~= LocalPlayer and p.Character then
                                if not p.Character:FindFirstChild("onze_bw_esp") then
                                    local h = Instance.new("Highlight")
                                    h.Name = "onze_bw_esp"
                                    h.FillColor = Color3.fromRGB(255, 50, 50)
                                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    h.FillTransparency = 0.4
                                    h.Parent = p.Character
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end

                -- Limpieza
                for _, p in Players:GetPlayers() do
                    if p.Character and p.Character:FindFirstChild("onze_bw_esp") then
                        p.Character:FindFirstChild("onze_bw_esp"):Destroy()
                    end
                end
            end)
        end
    })

    -- ESP Camas
    Tabs.Specific:AddToggle("BW_BedESP", {
        Title = "ESP Camas Enemigas",
        Description = "Resalta las camas enemigas a través de las paredes.",
        Default = false,
        Callback = function(Value)
            _G.BW_BedESP = Value
            task.spawn(function()
                while _G.BW_BedESP do
                    pcall(function()
                        for _, obj in workspace:GetDescendants() do
                            if obj:IsA("BasePart") then
                                local n = string.lower(obj.Name)
                                if string.find(n, "bed") and not obj:FindFirstChild("onze_bed_esp") then
                                    local h = Instance.new("Highlight")
                                    h.Name = "onze_bed_esp"
                                    h.FillColor = Color3.fromRGB(255, 200, 0)
                                    h.OutlineColor = Color3.fromRGB(255, 100, 0)
                                    h.FillTransparency = 0.3
                                    h.Parent = obj
                                end
                            end
                        end
                    end)
                    task.wait(3)
                end

                -- Limpieza
                for _, obj in workspace:GetDescendants() do
                    if obj:FindFirstChild("onze_bed_esp") then
                        obj:FindFirstChild("onze_bed_esp"):Destroy()
                    end
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento")

    -- Velocidad específica para Bedwars
    Tabs.Specific:AddSlider("BW_Speed", {
        Title = "Velocidad de Movimiento",
        Description = "Ajusta la velocidad del personaje en Bedwars.",
        Default = 16,
        Min = 16,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            pcall(function()
                local hum = getHum()
                if hum then hum.WalkSpeed = Value end
            end)
        end
    })

    -- High Jump
    Tabs.Specific:AddSlider("BW_JumpPower", {
        Title = "Altura de Salto",
        Description = "Aumenta la altura del salto.",
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

    -- Fly
    Tabs.Specific:AddToggle("BW_Fly", {
        Title = "Volar",
        Description = "Activa el modo vuelo. [Q] Bajar  [E] Subir",
        Default = false,
        Callback = function(Value)
            _G.BW_Fly = Value

            pcall(function()
                if Value then
                    local char = getChar()
                    local hrp  = getHRP()
                    local hum  = getHum()
                    if not (char and hrp and hum) then return end

                    hum.PlatformStand = true

                    local bp = Instance.new("BodyPosition")
                    bp.Name      = "onze_fly_bp"
                    bp.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
                    bp.Position  = hrp.Position
                    bp.Parent    = hrp

                    local bg = Instance.new("BodyGyro")
                    bg.Name     = "onze_fly_bg"
                    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                    bg.CFrame   = hrp.CFrame
                    bg.Parent   = hrp

                    local uis = game:GetService("UserInputService")
                    local flySpeed = 40

                    task.spawn(function()
                        while _G.BW_Fly and hrp and hrp.Parent do
                            pcall(function()
                                local cam = workspace.CurrentCamera
                                local dir = Vector3.new(0, 0, 0)

                                if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                                if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                                if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                                if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                                if uis:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
                                if uis:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end

                                if dir.Magnitude > 0 then
                                    bp.Position = bp.Position + dir.Unit * flySpeed * task.wait()
                                else
                                    task.wait(0.03)
                                end
                                bg.CFrame = workspace.CurrentCamera.CFrame
                            end)
                        end
                    end)
                else
                    local hrp = getHRP()
                    local hum = getHum()
                    if hrp then
                        local bp = hrp:FindFirstChild("onze_fly_bp")
                        local bg = hrp:FindFirstChild("onze_fly_bg")
                        if bp then bp:Destroy() end
                        if bg then bg:Destroy() end
                    end
                    if hum then hum.PlatformStand = false end
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades")

    -- Auto Collect Items
    Tabs.Specific:AddToggle("BW_AutoCollect", {
        Title = "Auto Recoger Recursos",
        Description = "Recoge automáticamente los recursos del suelo (hierro, oro, diamante, esmeralda).",
        Default = false,
        Callback = function(Value)
            _G.BW_AutoCollect = Value
            task.spawn(function()
                while _G.BW_AutoCollect do
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end

                        for _, obj in workspace:GetDescendants() do
                            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                                local n = string.lower(obj.Name)
                                if string.find(n, "iron") or string.find(n, "gold") or
                                   string.find(n, "diamond") or string.find(n, "emerald") or
                                   string.find(n, "hierro") or string.find(n, "oro") then
                                    local dist = (hrp.Position - obj.Position).Magnitude
                                    if dist < 50 then
                                        hrp.CFrame = CFrame.new(obj.Position)
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    })

    -- Rejoin rápido
    Tabs.Specific:AddButton({
        Title = "Rejoin (Respawn Rápido)",
        Description = "Te elimina para reaparecer en tu base en caso de quedar atrapado.",
        Callback = function()
            pcall(function()
                local hum = getHum()
                if hum then
                    hum.Health = 0
                    Fluent:Notify({Title = "onzeHub · Bedwars", Content = "Reapareciendo en tu base...", Duration = 3})
                end
            end)
        end
    })

    -- Canjear Códigos
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Activos",
        Description = "Intenta canjear automáticamente los códigos conocidos de Bedwars.",
        Callback = function()
            local codes = {
                "NOOBMASTER", "FREEGEMS", "BEDWARS2024", "HAPPYNEWYEAR",
                "SUMMER2024", "1BILVISITS", "FREESKIN", "CHRISTMAS2024",
                "HALLOWEEN2024", "THANKYOU100M", "ANNIVERSARY", "TWITCH",
                "DISCORD", "TWITTER", "YOUTUBE", "NOEL2024", "ROBLOX2024"
            }

            Fluent:Notify({Title = "onzeHub · Bedwars", Content = "Procesando " .. #codes .. " códigos...", Duration = 4})

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local remote = rs:FindFirstChild("RedeemCode", true)
                    or rs:FindFirstChild("CodeRedeem", true)
                    or rs:FindFirstChild("Codes", true)
                    or rs:FindFirstChild("redeem", true)

                if remote then
                    for _, code in ipairs(codes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(code)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(code)
                            end
                        end)
                        task.wait(0.3)
                    end
                    Fluent:Notify({Title = "onzeHub · Bedwars", Content = "Códigos enviados correctamente.", Duration = 4})
                else
                    Fluent:Notify({Title = "onzeHub · Bedwars", Content = "Remote de códigos no encontrado. Inténtalo en el lobby.", Duration = 5})
                end
            end)
        end
    })

end

return Module
