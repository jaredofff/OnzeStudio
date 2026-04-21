local GameModule = {}

function GameModule.Load(Tabs, Window, Fluent, Options)
    local MainSection = Tabs.Specific:AddSection("⚡ Afilado: Profesional")
    local ESPSection = Tabs.Specific:AddSection("👁️ Visuales Elite")
    local MovementSection = Tabs.Specific:AddSection("🚀 Movimiento Pro")
    
    local getgenv = getgenv or function() return _G end
    local env = getgenv()
    env.AfiladoKillAura = false
    env.AfiladoHitbox = false
    env.AfiladoESP = false
    env.AfiladoSpeed = false
    env.AfiladoInfJump = false
    
    -- [[ AFILADO: KillAura Professional ]]
    MainSection:AddToggle("AfiladoKillAura", {
        Title = "KillAura Elite", 
        Description = "Detecta y ataca automáticamente a los enemigos en un radio optimizado.",
        Default = false,
        Callback = function(state)
            env.AfiladoKillAura = state
            task.spawn(function()
                while env.AfiladoKillAura do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local weapon = char:FindFirstChildOfClass("Tool")
                            if weapon and weapon:FindFirstChild("Handle") then
                                for _, v in pairs(workspace:GetDescendants()) do
                                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= char then
                                        local targetHrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                                        if targetHrp and (targetHrp.Position - char.HumanoidRootPart.Position).Magnitude <= 20 then
                                            if firetouchinterest then
                                                firetouchinterest(weapon.Handle, targetHrp, 0)
                                                task.wait(0.01)
                                                firetouchinterest(weapon.Handle, targetHrp, 1)
                                            end
                                        end
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

    -- [[ AFILADO: Hitbox Expander ]]
    MainSection:AddToggle("AfiladoHitbox", {
        Title = "Hitbox Profesional", 
        Description = "Aumenta el tamaño de los enemigos para asegurar cada golpe.",
        Default = false,
        Callback = function(state)
            env.AfiladoHitbox = state
            task.spawn(function()
                while env.AfiladoHitbox do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= game.Players.LocalPlayer.Character then
                                local hrp = v:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.Size = Vector3.new(6, 6, 6)
                                    hrp.Transparency = 0.7
                                    hrp.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    })

    -- [[ VISUALES: ESP Profesionales ]]
    ESPSection:AddToggle("AfiladoESP", {
        Title = "ESP Ultra (Skelet/Box)", 
        Description = "Localiza a todos los jugadores en el mapa con alta precisión.",
        Default = false,
        Callback = function(state)
            env.AfiladoESP = state
            task.spawn(function()
                while env.AfiladoESP do
                    pcall(function()
                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player ~= game.Players.LocalPlayer and player.Character then
                                if not player.Character:FindFirstChild("Afilado_ESP") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "Afilado_ESP"
                                    hl.FillColor = Color3.fromRGB(0, 255, 255)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.FillTransparency = 0.5
                                    hl.Parent = player.Character
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                if not env.AfiladoESP then
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("Afilado_ESP") then
                            player.Character.Afilado_ESP:Destroy()
                        end
                    end
                end
            end)
        end
    })

    -- [[ MOVIMIENTO: CFrame Speed Elite ]]
    MovementSection:AddToggle("AfiladoSpeed", {
        Title = "Sprint Profesional (CFrame)", 
        Description = "Multiplica tu velocidad de movimiento de forma indetectable.",
        Default = false,
        Callback = function(state)
            env.AfiladoSpeed = state
            task.spawn(function()
                local rs = game:GetService("RunService")
                while env.AfiladoSpeed do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.75)
                        end
                    end)
                    rs.Heartbeat:Wait()
                end
            end)
        end
    })

    -- [[ MOVIMIENTO: Infinite Jump ]]
    MovementSection:AddToggle("AfiladoInfJump", {
        Title = "Saltos Infinitos Elite", 
        Description = "Vuela literalmente saltando infinitamente en el aire.",
        Default = false,
        Callback = function(state)
            env.AfiladoInfJump = state
            if state then
                game:GetService("UserInputService").JumpRequest:Connect(function()
                    if env.AfiladoInfJump then
                        pcall(function()
                            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                        end)
                    end
                end)
            end
        end
    })

    -- Premium Watermark specific to this module
    Fluent:Notify({
        Title = "onzeHub: AFILADO",
        Content = "Cargando configuración PROFESIONAL...",
        Duration = 5
    })
end

return GameModule
