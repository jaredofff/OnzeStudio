--[[
    onzeHub - Racket rivals
    ID: 134933804107672
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información")
    
    Tabs.Specific:AddParagraph({
        Title = "Racket rivals",
        Content = "Script base cargado correctamente. Puedes usar las funciones universales mientras se desarrollan funciones específicas para este juego."
    })
    
    Tabs.Specific:AddSection("Ventajas de Juego")

    Tabs.Specific:AddToggle("AutoSwing", {
        Title = "Auto Swing / Auto Hit (Beta)",
        Description = "Intenta golpear la pelota automáticamente cuando está cerca.",
        Default = false,
        Callback = function(Value)
            _G.AutoSwing = Value
            task.spawn(function()
                while _G.AutoSwing do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            for _, v in pairs(workspace:GetDescendants()) do
                                -- Buscar objetos que puedan ser la pelota
                                if v:IsA("BasePart") and string.find(string.lower(v.Name), "ball") then
                                    local dist = (char.HumanoidRootPart.Position - v.Position).Magnitude
                                    if dist < 15 then 
                                        -- Simular clic 
                                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                        task.wait(0.3) -- Cooldown para no spamear clics
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

    Tabs.Specific:AddToggle("BallHitbox", {
        Title = "Expandir Pelota (Hitbox)",
        Description = "Hace que la pelota sea gigante en tu pantalla para no fallar.",
        Default = false,
        Callback = function(Value)
            _G.ExpandBall = Value
            task.spawn(function()
                while _G.ExpandBall do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and string.find(string.lower(v.Name), "ball") then
                                v.Size = Vector3.new(12, 12, 12)
                                v.Transparency = 0.5
                                v.CanCollide = false -- Evita que interfiera con tu movimiento
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Visuales Avanzados")

    Tabs.Specific:AddToggle("BallESP", {
        Title = "Rastrear Pelota (Ball ESP)",
        Default = false,
        Callback = function(Value)
            _G.BallESP = Value
            task.spawn(function()
                while _G.BallESP do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and string.find(string.lower(v.Name), "ball") then
                                if not v:FindFirstChild("onze_ball_esp") then
                                    local h = Instance.new("Highlight")
                                    h.Name = "onze_ball_esp"
                                    h.FillColor = Color3.fromRGB(255, 255, 0)
                                    h.OutlineColor = Color3.fromRGB(255, 100, 0)
                                    h.Parent = v
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
                
                if not _G.BallESP then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:FindFirstChild("onze_ball_esp") then
                            v:FindFirstChild("onze_ball_esp"):Destroy()
                        end
                    end
                end
            end)
        end
    })

    -- ESP Mejorado con Nombres
    Tabs.Specific:AddToggle("PlayerESP", {
        Title = "ESP Jugadores (Chams)",
        Description = "Muestra a través de las paredes con mejor visibilidad.",
        Default = false,
        Callback = function(Value)
            _G.RacketESP = Value
            task.spawn(function()
                while _G.RacketESP do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= game.Players.LocalPlayer and v.Character then
                            local h = v.Character:FindFirstChild("onzeHub_RacketESP")
                            if not h then
                                h = Instance.new("Highlight")
                                h.Name = "onzeHub_RacketESP"
                                h.Parent = v.Character
                            end
                            h.FillColor = Color3.fromRGB(0, 255, 255)
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.FillTransparency = 0.5
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
                
                -- Cleanup
                if not _G.RacketESP then
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v.Character and v.Character:FindFirstChild("onzeHub_RacketESP") then
                            v.Character:FindFirstChild("onzeHub_RacketESP"):Destroy()
                        end
                    end
                end
            end)
        end
    })
end

return Module
