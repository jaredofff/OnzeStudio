--[[
    onzeHub - Poppy Playtime: UPDATED
    ID: 9748721976
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)

    local Players    = game:GetService("Players")
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
    Tabs.Specific:AddSection("Poppy Playtime VIP")

    Tabs.Specific:AddParagraph({
        Title = "🧸 Poppy Playtime: UPDATED",
        Content = "Tienes el control de Poppy Playtime. Escapa de los monstruos, encuentra objetos y sobrevive más tiempo que nadie."
    })

    -- =============================================
    -- [[ SUPERVIVENCIA ]]
    -- =============================================
    Tabs.Specific:AddSection("🏃 Supervivencia")

    -- Noclip / Atravesar paredes para escapar de monstruos
    Tabs.Specific:AddToggle("PP_Noclip", {
        Title = "Noclip (Atravesar Paredes)",
        Description = "Atraviesa paredes para escapar de Huggy Wuggy y monstruos.",
        Default = false,
        Callback = function(Value)
            _G.PP_Noclip = Value
            task.spawn(function()
                local RunService = game:GetService("RunService")
                local conn
                conn = RunService.Stepped:Connect(function()
                    if not _G.PP_Noclip then
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

    -- God Mode (salud infinita / regeneración)
    Tabs.Specific:AddToggle("PP_GodMode", {
        Title = "Modo Dios (Salud Infinita)",
        Description = "Los monstruos no te podrán matar.",
        Default = false,
        Callback = function(Value)
            _G.PP_GodMode = Value
            task.spawn(function()
                while _G.PP_GodMode do
                    pcall(function()
                        local hum = getHum()
                        if hum then
                            hum.Health = hum.MaxHealth
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    -- Velocidad de escape
    Tabs.Specific:AddSlider("PP_Speed", {
        Title = "Velocidad de Escape",
        Description = "Corre más rápido que cualquier monstruo.",
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

    -- High Jump para saltar obstáculos
    Tabs.Specific:AddSlider("PP_Jump", {
        Title = "Super Salto",
        Description = "Salta sobre los monstruos y obstáculos.",
        Default = 50,
        Min = 50,
        Max = 300,
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

    -- Fly para moverse por el mapa libremente
    Tabs.Specific:AddToggle("PP_Fly", {
        Title = "Volar (Fly Mode)",
        Description = "Vuela sobre todo el mapa. [W/S/A/D] + [E] Subir [Q] Bajar",
        Default = false,
        Callback = function(Value)
            _G.PP_Fly = Value
            pcall(function()
                local hrp  = getHRP()
                local hum  = getHum()
                if not hrp or not hum then return end

                if Value then
                    hum.PlatformStand = true

                    local bp = Instance.new("BodyPosition")
                    bp.Name     = "onze_pp_fly_bp"
                    bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bp.Position = hrp.Position
                    bp.Parent   = hrp

                    local bg = Instance.new("BodyGyro")
                    bg.Name      = "onze_pp_fly_bg"
                    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                    bg.CFrame    = hrp.CFrame
                    bg.Parent    = hrp

                    local uis = game:GetService("UserInputService")
                    task.spawn(function()
                        while _G.PP_Fly and hrp and hrp.Parent do
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
                    local bp = hrp:FindFirstChild("onze_pp_fly_bp")
                    local bg = hrp:FindFirstChild("onze_pp_fly_bg")
                    if bp then bp:Destroy() end
                    if bg then bg:Destroy() end
                    if hum then hum.PlatformStand = false end
                end
            end)
        end
    })

    -- =============================================
    -- [[ VISUALES ]]
    -- =============================================
    Tabs.Specific:AddSection("👁️ Visuales (ESP)")

    -- ESP Monstruos (Huggy, Mommy, Catnap, etc.)
    Tabs.Specific:AddToggle("PP_MonsterESP", {
        Title = "ESP Monstruos",
        Description = "Rastrea a Huggy Wuggy, Catnap, Mommy Long Legs y más a través de todo el mapa.",
        Default = false,
        Callback = function(Value)
            _G.PP_MonsterESP = Value
            task.spawn(function()
                local monsterKeywords = {"huggy", "mommy", "catnap", "boxy", "monster", "creature", "enemy", "npc", "villain", "poppy"}
                while _G.PP_MonsterESP do
                    pcall(function()
                        for _, obj in workspace:GetDescendants() do
                            if (obj:IsA("Model") or obj:IsA("BasePart")) and not obj:FindFirstChild("onze_pp_esp") then
                                local name = string.lower(obj.Name)
                                for _, kw in monsterKeywords do
                                    if string.find(name, kw) then
                                        local h = Instance.new("Highlight")
                                        h.Name = "onze_pp_esp"
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

                -- Cleanup
                for _, obj in workspace:GetDescendants() do
                    local esp = obj:FindFirstChild("onze_pp_esp")
                    if esp then esp:Destroy() end
                end
            end)
        end
    })

    -- FullBright para ver en los pasillos oscuros
    Tabs.Specific:AddToggle("PP_FullBright", {
        Title = "Brillo Total (FullBright)",
        Description = "Ilumina todos los pasillos oscuros de Playtime Co.",
        Default = false,
        Callback = function(Value)
            _G.PP_FullBright = Value
            local Lighting = game:GetService("Lighting")
            task.spawn(function()
                while _G.PP_FullBright do
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
    -- [[ UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("🎁 Utilidades VIP")

    Tabs.Specific:AddButton({
        Title = "Teletransportar a Spawn",
        Description = "Te teletransporta de vuelta al inicio del mapa si te quedas atascado.",
        Callback = function()
            pcall(function()
                local hrp = getHRP()
                local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildWhichIsA("SpawnLocation")
                if hrp and spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                    Fluent:Notify({Title = "onzeHub", Content = "¡Teletransportado al Spawn!", Duration = 3})
                else
                    Fluent:Notify({Title = "onzeHub", Content = "No se encontró el Spawn. Intenta en el lobby.", Duration = 3})
                end
            end)
        end
    })

end

return Module
