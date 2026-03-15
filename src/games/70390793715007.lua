--[[
    onzeHub - Hooked! Module
    ID: 70390793715007
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("PVP Élite")
    
    Tabs.Specific:AddToggle("AutoHook", {
        Title = "Auto Hook (Gancho Automático)",
        Description = "Lanza el gancho automáticamente cuando un enemigo está a tiro",
        Default = false,
        Callback = function(Value)
            _G.AutoHook = Value
            task.spawn(function()
                while _G.AutoHook do
                    pcall(function()
                        if _G.SilentHook and _G.CurrentTarget then
                            -- Simulación de click para lanzar el gancho
                            game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                            task.wait(1.5) -- Delay para no spamear cooldown
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("SilentHook", {
        Title = "Aimbot Predictivo (Silent)",
        Description = "Apunta al futuro del enemigo para que el gancho siempre conecte",
        Default = false,
        Callback = function(Value)
            _G.SilentHook = Value
            task.spawn(function()
                local Camera = workspace.CurrentCamera
                local RunService = game:GetService("RunService")
                while _G.SilentHook do
                    pcall(function()
                        local Target = nil
                        local MinDist = 500
                        local lp = game.Players.LocalPlayer
                        
                        for _, p in pairs(game.Players:GetPlayers()) do
                            local isEnemy = true
                            if p.Team and lp.Team and p.Team == lp.Team then isEnemy = false end
                            
                            if p ~= lp and isEnemy and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
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
                        
                        _G.CurrentTarget = Target
                        if Target then
                            local Root = Target.HumanoidRootPart
                            local Velocity = Root.Velocity
                            local Distance = (Camera.CFrame.Position - Root.Position).Magnitude
                            local TravelTime = Distance / 180 
                            local PredictedPos = Root.Position + (Velocity * TravelTime)
                            
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, PredictedPos), 0.15)
                        end
                    end)
                    RunService.RenderStepped:Wait()
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("HitboxExtender", {
        Title = "Hitbox Expander (Enemigos Gigantes)",
        Description = "Hace que los enemigos sean GIGANTES para acertar siempre",
        Default = false,
        Callback = function(Value)
            _G.HitboxExtender = Value
            task.spawn(function()
                while _G.HitboxExtender do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        for _, p in pairs(game.Players:GetPlayers()) do
                            local isEnemy = true
                            if p.Team and lp.Team and p.Team == lp.Team then isEnemy = false end
                            
                            if p ~= lp and isEnemy and p.Character then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.Size = Vector3.new(25, 25, 25)
                                    hrp.Transparency = 0.8
                                    hrp.CanCollide = false
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

    Tabs.Specific:AddSection("Defensa")

    Tabs.Specific:AddToggle("AntiHook", {
        Title = "Anti-Hook (Evasión)",
        Description = "Intenta esquivar ganchos enemigos automáticamente",
        Default = false,
        Callback = function(Value)
            _G.AntiHook = Value
            task.spawn(function()
                while _G.AntiHook do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = lp.Character.HumanoidRootPart
                            -- Buscar proyectiles de gancho cerca
                            for _, v in pairs(workspace:GetChildren()) do
                                if (v.Name == "Hook" or v.Name == "Grapple" or v:FindFirstChild("Hook")) and v:IsA("BasePart") then
                                    local dist = (hrp.Position - v.Position).Magnitude
                                    if dist < 20 then
                                        hrp.CFrame = hrp.CFrame * CFrame.new(12, 0, 0) -- Esquiva lateral brusca
                                    end
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    })
    
    Tabs.Specific:AddToggle("NoLava", {
        Title = "Inmunidad a Lava / Vacío Pro+",
        Description = "Vuela automáticamente si detecta peligro debajo de ti",
        Default = false,
        Callback = function(Value)
            _G.NoLava = Value
            task.spawn(function()
                local lp = game.Players.LocalPlayer
                while _G.NoLava do
                    pcall(function()
                        local char = lp.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local ray = Ray.new(hrp.Position, Vector3.new(0, -30, 0))
                            local part = workspace:FindPartOnRay(ray, char)
                            
                            if (part and (string.find(string.lower(part.Name), "lava") or string.find(string.lower(part.Name), "kill"))) or hrp.Position.Y < -35 then
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 85, hrp.Velocity.Z)
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
        Title = "ESP Enemigo (Rojo/Blanco)",
        Default = false,
        Callback = function(Value)
            _G.HookedESP = Value
            task.spawn(function()
                while _G.HookedESP do
                    for _, p in pairs(game.Players:GetPlayers()) do
                        local lp = game.Players.LocalPlayer
                        local isEnemy = true
                        if p.Team and lp.Team and p.Team == lp.Team then isEnemy = false end
                        
                        if p ~= lp and isEnemy and p.Character then
                            local h = p.Character:FindFirstChild("onzeHub_ESP") or Instance.new("Highlight")
                            h.Name = "onzeHub_ESP"
                            h.Parent = p.Character
                            h.FillColor = Color3.fromRGB(255, 0, 0)
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("onzeHub_ESP") then
                        p.Character.onzeHub_ESP:Destroy()
                    end
                end
            end)
        end
    })
end

return Module
