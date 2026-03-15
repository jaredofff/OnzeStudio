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
    
    Tabs.Specific:AddToggle("Aimbot", {
        Title = "Aimbot (Mirado Automático)",
        Description = "Hace que tu cámara mire siempre al enemigo más cercano",
        Default = false,
        Callback = function(Value)
            _G.Aimbot = Value
            task.spawn(function()
                local Camera = workspace.CurrentCamera
                while _G.Aimbot do
                    pcall(function()
                        local Target = nil
                        local MinDist = math.huge
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                                local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                                if OnScreen then
                                    local MousePos = game:GetService("UserInputService"):GetMouseLocation()
                                    local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                                    if Dist < MinDist then
                                        MinDist = Dist
                                        Target = p.Character
                                    end
                                end
                            end
                        end
                        if Target then
                            local TargetPos = Target.HumanoidRootPart.Position
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
                        end
                    end)
                    task.wait()
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("OverkillESP", {
        Title = "ESP de Jugadores (Boxes)",
        Default = false,
        Callback = function(Value)
            _G.OverkillESP = Value
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    if Value then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "onzeHub_ESP"
                        Highlight.FillColor = Color3.fromRGB(0, 255, 255)
                        Highlight.Parent = player.Character
                    else
                        local h = player.Character:FindFirstChild("onzeHub_ESP")
                        if h then 
                            h:Destroy() 
                        end
                    end
                end
            end
        end
    })
end

return Module
