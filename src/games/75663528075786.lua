--[[
    onzeHub - How to Train Your Dragon (Élite)
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
        Description = "Ataca automáticamente a mobs cercanos para subir nivel",
        Default = false,
        Callback = function(Value)
            _G.DragonFarm = Value
            task.spawn(function()
                while _G.DragonFarm do
                    pcall(function()
                        local lp = game.Players.LocalPlayer
                        local char = lp.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            -- Buscar enemigos (Mobs) en el Workspace
                            -- Nota: En este juego los mobs suelen estar en carpetas como 'Mobs' o directamente en Workspace
                            for _, mob in pairs(workspace:GetChildren()) do
                                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                                    local dist = (char.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                                    if dist < 50 then
                                        -- Simulación de ataque (Click o Remote)
                                        game:GetService("VirtualInputManager"):ClickButton1(Vector2.new(0,0))
                                        task.wait(0.5)
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
        Title = "Auto Clicker (Ataque Rápido)",
        Description = "Hace clicks automáticos constantes",
        Default = false,
        Callback = function(Value)
            _G.AutoAttack = Value
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
        Title = "Velocidad de Movimiento",
        Description = "Aumenta la velocidad al caminar y volar",
        Default = 16,
        Min = 16,
        Max = 250,
        Rounding = 1,
        Callback = function(Value)
            _G.DragonSpeed = Value
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end
    })

    Tabs.Specific:AddToggle("InfStamina", {
        Title = "Stamina Infinita (Vuelo)",
        Description = "Te permite volar sin cansarte (Si el juego lo permite)",
        Default = false,
        Callback = function(Value)
            _G.InfiniteStamina = Value
            task.spawn(function()
                while _G.InfiniteStamina do
                    pcall(function()
                        -- Buscar valores de Stamina en el Personaje o PlayerGui
                        local stamina = game.Players.LocalPlayer.Character:FindFirstChild("Stamina", true) or game.Players.LocalPlayer:FindFirstChild("Stamina", true)
                        if stamina and stamina:IsA("NumberValue") or stamina:IsA("IntValue") then
                            stamina.Value = 100
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
        Title = "Canjear Todos los Códigos META",
        Description = "Canjea automáticamente códigos de Trait Rerolls y Huevos",
        Callback = function()
            local codes = {"ONAROLL", "THANKYOU20K", "MORETRAITS", "SKRILLISSUE", "ABCDEF", "SORRY4DELAY", "EGGCELENT"}
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Events", true) and game:GetService("ReplicatedStorage"):FindFirstChild("Events", true):FindFirstChild("RedeemCode")
            
            for _, code in pairs(codes) do
                if remote then
                    remote:FireServer(code)
                else
                    -- Fallback: Notificar si no se encuentra el remote
                    Fluent:Notify({
                        Title = "onzeHub",
                        Content = "Intentando canjear: " .. code,
                        Duration = 2
                    })
                end
                task.wait(0.5)
            end
        end
    })

    -- [[ PESTAÑA: VISUALES ]]
    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("DragonESP", {
        Title = "ESP de Jugadores y Mobs",
        Default = false,
        Callback = function(Value)
            _G.DragonESP = Value
            task.spawn(function()
                while _G.DragonESP do
                    -- ESP para Jugadores
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= game.Players.LocalPlayer and p.Character then
                            local h = p.Character:FindFirstChild("onzeHub_ESP") or Instance.new("Highlight")
                            h.Name = "onzeHub_ESP"
                            h.Parent = p.Character
                            h.FillColor = Color3.fromRGB(0, 255, 255)
                            h.OutlineColor = Color3.fromRGB(255, 255, 255)
                            h.Enabled = true
                        end
                    end
                    task.wait(2)
                end
                -- Limpieza
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
        task.wait(1)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = _G.DragonSpeed
    end)
end

return Module
