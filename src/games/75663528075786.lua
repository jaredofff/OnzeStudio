--[[
    onzeHub - How to Train Your Dragon (Master Farm V2)
    ID: 75663528075786
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    -- Variables de Estado
    _G.DragonMasterFarm = false
    _G.KillAura = false
    _G.AutoCollect = false
    _G.FastAttack = false

    -- Función para encontrar enemigos optimizada
    local function GetEnemies()
        local enemies = {}
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return enemies end
        
        -- Escaneo más ligero: Solo hijos directos del workspace o modelos con Humanoid
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                if v ~= char and not game.Players:GetPlayerFromCharacter(v) then
                    table.insert(enemies, v)
                end
            end
        end
        return enemies
    end

    -- [[ PESTAÑA: FARMING EXTREMO ]]
    Tabs.Specific:AddSection("Farming de Nivel y Gemas")
    
    Tabs.Specific:AddToggle("MasterFarm", {
        Title = "Master Farm (Nivel Rápido)",
        Description = "Ataca mobs cercanos. Úsalo cerca de grupos de enemigos.",
        Default = false,
        Callback = function(Value)
            _G.DragonMasterFarm = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Master Farm ACTIVADO. Buscando mobs...", Duration = 3})
            end
            task.spawn(function()
                while _G.DragonMasterFarm do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local enemies = GetEnemies()
                            for _, mob in pairs(enemies) do
                                local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("PrimaryPart")
                                if hrp then
                                    local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                                    if dist < 60 then
                                        -- Forzar ataque
                                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("KillAura", {
        Title = "Kill Aura (Radio 70m)",
        Description = "Limpia la zona automáticamente. No requiere clics manuales.",
        Default = false,
        Callback = function(Value)
            _G.KillAura = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Kill Aura ACTIVADO. Limpiando área...", Duration = 2})
            end
            task.spawn(function()
                while _G.KillAura do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        local enemies = GetEnemies()
                        
                        for _, mob in pairs(enemies) do
                            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("PrimaryPart")
                            if hrp then
                                local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist < 70 then
                                    -- Intentar atacar vía Remotes del juego (común en Dragon games)
                                    local rs = game:GetService("ReplicatedStorage")
                                    local attackRemote = rs:FindFirstChild("Attack", true) or rs:FindFirstChild("Hit", true) or rs:FindFirstChild("Combat", true)
                                    
                                    if attackRemote and attackRemote:IsA("RemoteEvent") then
                                        attackRemote:FireServer(mob)
                                    end
                                    
                                    -- Siempre usar Click como respaldo
                                    game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("AutoCollect", {
        Title = "Auto-Loot (Items/Gemas)",
        Description = "Recoge automáticamente gemas y cofres cercanos.",
        Default = false,
        Callback = function(Value)
            _G.AutoCollect = Value
            task.spawn(function()
                while _G.AutoCollect do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        for _, item in pairs(workspace:GetDescendants()) do
                            if item:IsA("BasePart") or item:IsA("Model") then
                                local lowerName = string.lower(item.Name)
                                if string.find(lowerName, "gem") or string.find(lowerName, "chest") or string.find(lowerName, "coin") or string.find(lowerName, "egg") then
                                    local targetPos = item:IsA("BasePart") and item.Position or (item.PrimaryPart and item.PrimaryPart.Position)
                                    if targetPos then
                                        local dist = (char.HumanoidRootPart.Position - targetPos).Magnitude
                                        if dist < 120 then
                                            -- Teleport rápido y vuelta (opcionalmente solo mover un poco)
                                            local oldPos = char.HumanoidRootPart.CFrame
                                            char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                                            task.wait(0.1)
                                            char.HumanoidRootPart.CFrame = oldPos
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    })

    -- [[ PESTAÑA: MEJORAS ]]
    Tabs.Specific:AddSection("Mejoras de Jinete")
    
    Tabs.Specific:AddSlider("WalkSpeed", {
        Title = "Velocidad Total",
        Default = 16,
        Min = 16,
        Max = 400,
        Rounding = 1,
        Callback = function(Value)
            _G.DragonSpeed = Value
            local lp = game.Players.LocalPlayer
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = Value
            end
        end
    })

    Tabs.Specific:AddToggle("InfiniteFly", {
        Title = "Vuelo Infinito (Sin Cansancio)",
        Default = false,
        Callback = function(Value)
            _G.InfFly = Value
            task.spawn(function()
                while _G.InfFly do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        -- Forzar barra de stamina al máximo
                        local s = lp.Character:FindFirstChild("Stamina", true) or lp:FindFirstChild("Stamina", true)
                        if s then 
                            s.Value = 100 
                        end
                        
                        -- En muchos juegos es un NumberValue dentro de un script
                        for _, v in pairs(lp.Character:GetDescendants()) do
                            if v.Name == "Stamina" or v.Name == "Energy" then
                                v.Value = 100
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })

    -- [[ UTILIDADES ]]
    Tabs.Specific:AddSection("Utilidades")
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos META",
        Callback = function()
            local codes = {"DRAGONS", "GEMS", "ONAROLL", "COOKING", "SORRY4DELAY", "ABCDEF", "THANKYOU20K"}
            local rs = game:GetService("ReplicatedStorage")
            local remote = rs:FindFirstChild("RedeemCode", true)
            for _, code in pairs(codes) do
                if remote then 
                    remote:FireServer(code) 
                end
            end
            Fluent:Notify({Title = "onzeHub", Content = "Códigos procesados.", Duration = 2})
        end
    })

    -- [[ VISUALES ]]
    Tabs.Specific:AddSection("Visuales")
    Tabs.Specific:AddToggle("DragonESP", {
        Title = "ESP (Jugadores y Criaturas)",
        Default = false,
        Callback = function(Value)
            _G.DragonESP = Value
            task.spawn(function()
                while _G.DragonESP do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= game.Players.LocalPlayer and v.Character then
                            local h = v.Character:FindFirstChild("onzeHub_ESP")
                            if not h then
                                h = Instance.new("Highlight")
                                h.Name = "onzeHub_ESP"
                                h.Parent = v.Character
                            end
                            h.FillColor = Color3.fromRGB(255, 0, 50)
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    })

    -- Persistencia de velocidad
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(2)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = _G.DragonSpeed or 16
    end)
end

return Module
