--[[
    onzeHub - How to Train Your Dragon (Élite Debug)
    ID: 75663528075786
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    -- Variables de Estado
    _G.DragonFarm = false
    _G.AutoAttack = false
    _G.DragonSpeed = 16
    _G.InfiniteStamina = false

    -- [[ PESTAÑA: AUTOMATIZACIÓN ]]
    Tabs.Specific:AddSection("Farming Maestro")
    
    Tabs.Specific:AddToggle("AutoFarm", {
        Title = "Auto Farm XP (Combate)",
        Description = "Ataca mobs cercanos. Úsalo cerca de enemigos.",
        Default = false,
        Callback = function(Value)
            _G.DragonFarm = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Auto Farm ACTIVADO. Acércate a un enemigo.", Duration = 3})
            end
            task.spawn(function()
                while _G.DragonFarm do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            for _, mob in pairs(workspace:GetChildren()) do
                                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                    local dist = (char.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                                    if dist < 40 then
                                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
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

    Tabs.Specific:AddToggle("AutoClicker", {
        Title = "Auto Clicker (Ataque)",
        Description = "Clicks constantes para daño máximo",
        Default = false,
        Callback = function(Value)
            _G.AutoAttack = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Auto Clicker ACTIVADO.", Duration = 2})
            end
            task.spawn(function()
                while _G.AutoAttack do
                    pcall(function()
                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    -- [[ PESTAÑA: MEJORAS DRAGÓN ]]
    Tabs.Specific:AddSection("Atributos del Dragón")
    
    Tabs.Specific:AddSlider("WalkSpeed", {
        Title = "Velocidad",
        Default = 16,
        Min = 16,
        Max = 250,
        Rounding = 1,
        Callback = function(Value)
            _G.DragonSpeed = Value
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
                Fluent:Notify({Title = "onzeHub", Content = "Velocidad ajustada a: " .. Value, Duration = 1})
            end
        end
    })

    Tabs.Specific:AddToggle("InfStamina", {
        Title = "Stamina Infinita (Vuelo)",
        Default = false,
        Callback = function(Value)
            _G.InfiniteStamina = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "Stamina Infinita ACTIVADA.", Duration = 2})
            end
            task.spawn(function()
                while _G.InfiniteStamina do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char then
                            local stam = char:FindFirstChild("Stamina", true)
                            if stam and (stam:IsA("NumberValue") or stam:IsA("IntValue")) then
                                stam.Value = 100
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })

    -- [[ PESTAÑA: UTILIDADES ]]
    Tabs.Specific:AddSection("Utilidades VIP")

    Tabs.Specific:AddButton({
        Title = "PROBAR: Notificación de Test",
        Callback = function()
            Fluent:Notify({Title = "onzeHub", Content = "¡Si ves esto, el script está respondiendo!", Duration = 5})
        end
    })

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Actualizados",
        Callback = function()
            local codes = {
                "DRAGONS", "ONAROLL", "COOKING", "THANKYOU20K", "SNOGGLETOG", 
                "YAKNOG", "FLORAL", "SKRILLISSUE", "GEMS", "MORETRAITS", 
                "ITTAKESTWO", "PEACOCKEGG", "USEYURHEAD", "DRAGONS4L", 
                "ABCDEF", "EGGCELENT", "RISKYR", "SORRY4DELAY"
            }
            Fluent:Notify({Title = "onzeHub", Content = "Iniciando canje masivo...", Duration = 3})
            for _, code in pairs(codes) do
                pcall(function()
                    local rs = game:GetService("ReplicatedStorage")
                    local remote = rs:FindFirstChild("RedeemCode", true) or rs:FindFirstChild("Events", true):FindFirstChild("RedeemCode")
                    if remote then
                        remote:FireServer(code)
                    end
                end)
                task.wait(0.5)
            end
            Fluent:Notify({Title = "onzeHub", Content = "Proceso de códigos finalizado.", Duration = 3})
        end
    })

    -- [[ PESTAÑA: VISUALES ]]
    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("DragonESP", {
        Title = "ESP Enemigo (Rojo)",
        Default = false,
        Callback = function(Value)
            _G.DragonESP = Value
            if Value then
                Fluent:Notify({Title = "onzeHub", Content = "ESP ACTIVADO.", Duration = 2})
            end
            task.spawn(function()
                while _G.DragonESP do
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= game.Players.LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("onzeHub_ESP") or Instance.new("Highlight")
                            h.Name = "onzeHub_ESP"
                            h.Parent = p.Character
                            h.FillColor = Color3.fromRGB(255, 0, 0)
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

    -- Mantener Velocidad al reaparecer
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1.5)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = _G.DragonSpeed
    end)
end

return Module
