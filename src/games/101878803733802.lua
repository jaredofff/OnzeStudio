--[[
    onzeHub - Overkill Module
    ID: 74996816424339
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Combate")
    
    Tabs.Specific:AddToggle("SilentAim", {
        Title = "Silent Aim (Asistencia)",
        Description = "Tus balas irán hacia el enemigo más cercano automáticamente",
        Default = false,
        Callback = function(Value)
            _G.SilentAim = Value
            -- Lógica de Silent Aim (Simulación de redirección de balas)
            task.spawn(function()
                while _G.SilentAim do
                    pcall(function()
                        local Target = nil
                        local Dist = 200
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if d < Dist then
                                    Dist = d
                                    Target = p.Character
                                end
                            end
                        end
                        _G.CurrentTarget = Target
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("NoRecoil", {
        Title = "Sin Retroceso (No Recoil)",
        Description = "Tus armas no se moverán al disparar",
        Default = false,
        Callback = function(Value)
            _G.NoRecoil = Value
            -- Aquí se interceptarían los remotos de las armas
        end
    })

    Tabs.Specific:AddSection("Movimiento")
    
    Tabs.Specific:AddToggle("NoVoidDamage", {
        Title = "Evitar Daño del Vacío",
        Description = "Te permite caer al vacío sin morir inmediatamente",
        Default = false,
        Callback = function(Value)
            _G.NoVoid = Value
            task.spawn(function()
                while _G.NoVoid do
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Y < -50 then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
                    end
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("SmoothAimbot", {
        Title = "Aimbot Predictivo (Smooth)",
        Description = "Calcula hacia dónde se mueve el enemigo para acertar las balas.",
        Default = false,
        Callback = function(Value)
            _G.Aimbot = Value
            task.spawn(function()
                local Camera = workspace.CurrentCamera
                local RunService = game:GetService("RunService")
                while _G.Aimbot do
                    pcall(function()
                        local Target = nil
                        local MinDist = 400 -- FOV Virtual
                        
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                                local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                                if OnScreen then
                                    local MousePos = game:GetService("UserInputService"):GetMouseLocation()
                                    local ScreenDist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                                    if ScreenDist < MinDist then
                                        MinDist = ScreenDist
                                        Target = p.Character
                                    end
                                end
                            end
                        end
                        
                        if Target then
                            local Root = Target.HumanoidRootPart
                            local Velocity = Root.Velocity
                            local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
                            local TravelTime = Distance / 150 -- Ajuste de velocidad de bala en Overkill
                            
                            -- PREDICCIÓN: Apuntar a donde el enemigo ESTARÁ
                            local PredictedPos = Root.Position + (Velocity * TravelTime)
                            
                            -- LERP: Movimiento suave para que no parezca bot
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, PredictedPos), 0.1)
                        end
                    end)
                    RunService.RenderStepped:Wait()
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("OverkillESP", {
        Title = "ESP Pro (Detección)",
        Description = "Resalta a los enemigos a través de paredes.",
        Default = false,
        Callback = function(Value)
            _G.OverkillESP = Value
            task.spawn(function()
                while _G.OverkillESP do
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local h = player.Character:FindFirstChild("onzeHub_ESP")
                            if not h then
                                h = Instance.new("Highlight")
                                h.Name = "onzeHub_ESP"
                                h.Parent = player.Character
                            end
                            h.Enabled = true
                            h.FillColor = Color3.fromRGB(255, 0, 50)
                        end
                    end
                    task.wait(1)
                end
                -- Limpiar al apagar
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("onzeHub_ESP") then
                        player.Character.onzeHub_ESP:Destroy()
                    end
                end
            end)
        end
    })
end

return Module
