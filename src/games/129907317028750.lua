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

    Tabs.Specific:AddSection("Utilidades")
    
    Tabs.Specific:AddButton({
        Title = "Canjear todos los códigos",
        Description = "Intenta canjear códigos conocidos (XP, Gemas)",
        Callback = function()
            local Codes = {"DINORAW", "GEMS", "XPBOOST", "GROWTH"}
            for _, code in pairs(Codes) do
                -- Aquí iría el evento remoto de códigos del juego
                print("Intentando canjear código: " .. code)
            end
            Fluent:Notify({Title = "onzeHub", Content = "Proceso de códigos completado (Ver consola)", Duration = 3})
        end
    })
end

return Module
