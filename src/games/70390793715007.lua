--[[
    onzeHub - Hooked! Module
    ID: 70390793715007
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("PVP y Combate")
    
    Tabs.Specific:AddToggle("SilentHook", {
        Title = "Silent Hook (Aimbot)",
        Description = "Apunta automáticamente tu gancho al enemigo más cercano",
        Default = false,
        Callback = function(Value)
            _G.SilentHook = Value
            task.spawn(function()
                local Camera = workspace.CurrentCamera
                while _G.SilentHook do
                    pcall(function()
                        local Target = nil
                        local MinDist = 150
                        for _, p in pairs(game.Players:GetPlayers()) do
                            local lp = game.Players.LocalPlayer
                            if p ~= lp and (not p.Team or p.Team ~= lp.Team) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                                local Dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if Dist < MinDist then
                                    MinDist = Dist
                                    Target = p.Character
                                end
                            end
                        end
                        if Target then
                            local TargetPos = Target.HumanoidRootPart.Position
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), 0.2)
                        end
                    end)
                    task.wait()
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("KillAura", {
        Title = "Kill Aura (Auto-Atacar)",
        Description = "Ataca automáticamente a jugadores muy cercanos",
        Default = false,
        Callback = function(Value)
            _G.HookedKillAura = Value
            task.spawn(function()
                while _G.HookedKillAura do
                    pcall(function()
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < 15 then
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

    Tabs.Specific:AddToggle("HitboxExtender", {
        Title = "Hitbox Extender Pro",
        Description = "Hace que los enemigos sean GIGANTES para acertar siempre",
        Default = false,
        Callback = function(Value)
            _G.HitboxExtender = Value
            task.spawn(function()
                while _G.HitboxExtender do
                    pcall(function()
                        for _, p in pairs(game.Players:GetPlayers()) do
                            if p ~= game.Players.LocalPlayer and p.Character then
                                local root = p.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    root.Size = Vector3.new(25, 25, 25)
                                    root.Transparency = 0.8
                                    root.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                -- Reset
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                        p.Character.HumanoidRootPart.Transparency = 1
                    end
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Movimiento y Supervivencia")
    
    Tabs.Specific:AddToggle("NoLava", {
        Title = "Inmunidad a Lava / Arena",
        Description = "Te impulsa hacia arriba si caes al peligro",
        Default = false,
        Callback = function(Value)
            _G.NoLava = Value
            task.spawn(function()
                while _G.NoLava do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            if char.HumanoidRootPart.Position.Y < -5 then
                                char.HumanoidRootPart.Velocity = Vector3.new(0, 60, 0)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("HookedESP", {
        Title = "ESP de Jugadores (Brillo)",
        Default = false,
        Callback = function(Value)
            _G.HookedESP = Value
            task.spawn(function()
                while _G.HookedESP do
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local h = player.Character:FindFirstChild("onzeHub_ESP")
                            if not h then
                                h = Instance.new("Highlight")
                                h.Name = "onzeHub_ESP"
                                h.Parent = player.Character
                            end
                            h.FillColor = Color3.fromRGB(0, 255, 100)
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
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
