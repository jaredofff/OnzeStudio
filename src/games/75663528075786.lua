--[[
    onzeHub - How to Train Your Dragon (Master Farm)
    ID: 75663528075786
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    -- Variables de Estado
    _G.DragonMasterFarm = false
    _G.KillAura = false
    _G.AutoCollect = false
    _G.FastAttack = false

    -- [[ PESTAÑA: FARMING EXTREMO ]]
    Tabs.Specific:AddSection("Farming de Nivel y Gemas")
    
    Tabs.Specific:AddToggle("MasterFarm", {
        Title = "Master Farm (Nivel Rápido)",
        Description = "Teletransporta a mobs y los elimina para subir nivel masivamente.",
        Default = false,
        Callback = function(Value)
            _G.DragonMasterFarm = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Master Farm ACTIVADO. Iniciando subida de nivel...", Duration = 3})
            end
            task.spawn(function()
                while _G.DragonMasterFarm do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            for _, mob in pairs(workspace:GetChildren()) do
                                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                    local dist = (char.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                                    if dist < 100 then
                                        -- Opción: Teletransportarse suavemente o solo atacar
                                        -- char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("KillAura", {
        Title = "Kill Aura (Radio 50m)",
        Description = "Elimina automáticamente todo lo que esté cerca de tu dragón.",
        Default = false,
        Callback = function(Value)
            _G.KillAura = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Kill Aura ACTIVADO.", Duration = 2})
            end
            task.spawn(function()
                while _G.KillAura do
                    pcall(function()
                        for _, v in pairs(workspace:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                                local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                                if dist < 50 then
                                    -- Ataque remoto si se encuentra (común en estos juegos)
                                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Attack", true) or game:GetService("ReplicatedStorage"):FindFirstChild("Hit", true)
                                    if remote then
                                        remote:FireServer(v)
                                    else
                                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("AutoCollect", {
        Title = "Auto-Recolectar (Gemas/Items)",
        Description = "Loot automático de gemas, cofres y comida del mapa.",
        Default = false,
        Callback = function(Value)
            _G.AutoCollect = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Buscando gemas y tesoros...", Duration = 3})
            end
            task.spawn(function()
                while _G.AutoCollect do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        for _, item in pairs(workspace:GetChildren()) do
                            -- Nombres comunes de items en este juego
                            if string.find(string.lower(item.Name), "gem") or string.find(string.lower(item.Name), "chest") or string.find(string.lower(item.Name), "egg") or string.find(string.lower(item.Name), "coin") then
                                if item:IsA("BasePart") or item:FindFirstChildWhichIsA("BasePart") then
                                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                                    local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                                    if dist < 100 then
                                        char.HumanoidRootPart.CFrame = part.CFrame
                                        task.wait(0.2)
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

    -- [[ PESTAÑA: MEJORAS ]]
    Tabs.Specific:AddSection("Mejoras de Jinete")
    
    Tabs.Specific:AddSlider("WalkSpeed", {
        Title = "Velocidad de Vuelo/Caminar",
        Default = 16,
        Min = 16,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end
    })

    Tabs.Specific:AddToggle("InfiniteFly", {
        Title = "Vuelo Infinito / Sin Stamina",
        Default = false,
        Callback = function(Value)
            _G.InfFly = Value
            task.spawn(function()
                while _G.InfFly do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char then
                            local s = char:FindFirstChild("Stamina", true) or lp:FindFirstChild("Stamina", true)
                            if s then s.Value = 100 end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Utilidades")
    
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos de Gemas/Stats",
        Description = "Canjea todos los códigos activos para gemas gratis.",
        Callback = function()
            local codes = {"DRAGONS", "GEMS", "ONAROLL", "COOKING", "SORRY4DELAY", "ABCDEF", "THANKYOU20K"}
            for _, code in pairs(codes) do
                pcall(function()
                    game:GetService("ReplicatedStorage"):FindFirstChild("RedeemCode", true):FireServer(code)
                end)
            end
            Fluent:Notify({Title = "onzeHub", Content = "Códigos procesados. Revisa tus gemas.", Duration = 3})
        end
    })

    -- [[ VISUALES ]]
    Tabs.Specific:AddSection("Visuales")
    Tabs.Specific:AddToggle("ESP", {
        Title = "ESP de Jugadores y Mobs",
        Default = false,
        Callback = function(Value)
            _G.ESP = Value
            task.spawn(function()
                while _G.ESP do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= game.Players.LocalPlayer and v.Character then
                            local h = v.Character:FindFirstChild("Highlight") or Instance.new("Highlight", v.Character)
                            h.FillColor = Color3.fromRGB(255, 0, 100)
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    })
end

return Module
