--[[
    onzeHub - Be Dino Module
    ID: 129907317028750
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Supervivencia y Escape")
    
    Tabs.Specific:AddToggle("SpeedBoost", {
        Title = "Súper Velocidad (Shift)",
        Description = "Mantén SHIFT para correr más rápido",
        Default = false,
        Callback = function(Value)
            _G.SpeedBoost = Value
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.LeftShift and _G.SpeedBoost then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 60
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
                end
            end)
        end
    })

    Tabs.Specific:AddButton({
        Title = "Teletransporte de Escape",
        Description = "Te lanza a una posición aleatoria lejos (Ideal para huir)",
        Callback = function()
            local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
            local RandomPos = Root.Position + Vector3.new(math.random(-200, 200), 20, math.random(-200, 200))
            Root.CFrame = CFrame.new(RandomPos)
            Fluent:Notify({Title = "onzeHub", Content = "¡Escapaste!", Duration = 2})
        end
    })

    Tabs.Specific:AddToggle("AutoEat", {
        Title = "Auto Comer (Comida cercana)",
        Description = "Intenta comer comida automáticamente cuando estés cerca",
        Default = false,
        Callback = function(Value)
            _G.AutoEat = Value
            task.spawn(function()
                while _G.AutoEat do
                    pcall(function()
                        -- Lógica simple para detectar comida (Meat/Hatchling)
                        for _, v in pairs(workspace:GetChildren()) do
                            if v:FindFirstChild("Meat") or v.Name:find("Egg") then
                                local Distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                                if Distance < 15 then
                                    -- Aquí iría el evento de comer del juego
                                    print("Comida detectada cerca!")
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("PlayerESP", {
        Title = "ESP de Jugadores (Dinos)",
        Description = "Resalta a otros dinosaurios en el mapa",
        Default = false,
        Callback = function(Value)
            _G.DinoESP = Value
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    if Value then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "onzeHub_ESP"
                        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        Highlight.Parent = player.Character
                    else
                        local h = player.Character:FindFirstChild("onzeHub_ESP")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    })

    Tabs.Specific:AddSection("Movimiento Pro")
    
    Tabs.Specific:AddToggle("NoClip", {
        Title = "Atravesar Paredes (NoClip)",
        Default = false,
        Callback = function(Value)
            _G.NoClip = Value
            game:GetService("RunService").Stepped:Connect(function()
                if _G.NoClip and game.Players.LocalPlayer.Character then
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("FlyDino", {
        Title = "Vuelo (Fly)",
        Description = "Te permite volar por el mapa (Cuidado con los reportes)",
        Default = false,
        Callback = function(Value)
            -- Lógica simple de vuelo para Solara
            if Value then
                local bcl = Instance.new("BodyVelocity")
                bcl.Name = "onzeFly"
                bcl.Velocity = Vector3.new(0, 0, 0)
                bcl.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bcl.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
            else
                local f = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("onzeFly")
                if f then f:Destroy() end
            end
        end
    })

    Tabs.Specific:AddSection("Visuales Pro")
    
    Tabs.Specific:AddButton({
        Title = "Brillo Total (Visión Nocturna)",
        Callback = function()
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
        end
    })

    Tabs.Specific:AddSection("Utilidades y Códigos")
    
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Reales (Marzo 2026)",
        Description = "Intenta canjear: CONTEST, KEEPIT100K, ABSTRAK, CHOTU, GALAXY, 75KLIKES...",
        Callback = function()
            local Codes = {"CONTEST", "KEEPIT100K", "ABSTRAK", "CHOTU", "HEVY", "GALAXY", "75KLIKES", "AMBER"}
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            -- Intentar encontrar el evento de códigos (varía según el juego)
            local Remote = ReplicatedStorage:FindFirstChild("CodeRemote") or ReplicatedStorage:FindFirstChild("RedeemCode") or ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("RedeemCode")
            
            if Remote then
                for _, code in pairs(Codes) do
                    Remote:FireServer(code)
                    task.wait(0.5)
                end
                Fluent:Notify({Title = "onzeHub", Content = "Códigos enviados al servidor", Duration = 3})
            else
                warn("onzeHub: No se encontró el evento remoto de códigos. Intenta canjear uno manualmente primero para que el script lo detecte.")
            end
        end
    })

    Tabs.Specific:AddSection("Caza Automática")

    Tabs.Specific:AddToggle("KillAura", {
        Title = "Kill Aura Pro (Auto Atacar)",
        Description = "Apunta y ataca automáticamente a dinosaurios cercanos",
        Default = false,
        Callback = function(Value)
            _G.KillAura = Value
            task.spawn(function()
                while _G.KillAura do
                    pcall(function()
                        local LocalPlayer = game.Players.LocalPlayer
                        local Character = LocalPlayer.Character
                        if not Character then return end
                        
                        local ClosestDino = nil
                        local MinDist = 25
                        
                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local Dist = (Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                if Dist < MinDist then
                                    MinDist = Dist
                                    ClosestDino = player.Character
                                end
                            end
                        end
                        
                        if ClosestDino then
                            -- Apuntar al dinosaurio (LookAt)
                            local TargetPos = ClosestDino.HumanoidRootPart.Position
                            Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Vector3.new(TargetPos.X, Character.HumanoidRootPart.Position.Y, TargetPos.Z))
                            
                            -- Simular el ataque (Bite)
                            game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Crecimiento Rápido (Dino Top)")

    Tabs.Specific:AddToggle("AutoFood", {
        Title = "Buscar Comida Automáticamente",
        Description = "Te gira hacia la comida más cercana (Meat/Eggs/Plants)",
        Default = false,
        Callback = function(Value)
            _G.AutoFood = Value
            task.spawn(function()
                while _G.AutoFood do
                    pcall(function()
                        local Character = game.Players.LocalPlayer.Character
                        if not Character then return end

                        local FoodNames = {"Meat", "Egg", "Food", "Plant"}
                        local ClosestFood = nil
                        local MinDist = 150

                        for _, v in pairs(workspace:GetDescendants()) do
                            local IsFood = false
                            for _, name in pairs(FoodNames) do
                                if v.Name:find(name) and v:IsA("BasePart") then
                                    IsFood = true
                                    break
                                end
                            end

                            if IsFood then
                                local Dist = (Character.HumanoidRootPart.Position - v.Position).Magnitude
                                if Dist < MinDist then
                                    MinDist = Dist
                                    ClosestFood = v
                                end
                            end
                        end

                        if ClosestFood then
                            -- Girar hacia la comida
                            Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Vector3.new(ClosestFood.Position.X, Character.HumanoidRootPart.Position.Y, ClosestFood.Position.Z))
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })
end

return Module
