--[[
    onzeHub - Abyss
    ID: 127794225497302
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información VIP")
    
    Tabs.Specific:AddParagraph({
        Title = "✨ Abyss Premium Control",
        Content = "Bienvenido a Abyss. Cuidado con las profundidades. Tu plan premium te da ventajas sobre el resto de buzos y pescadores."
    })
    
    Tabs.Specific:AddSection("🎣 Auto-Farming (Pesca Avanzada)")

    Tabs.Specific:AddToggle("AutoCast", {
        Title = "Auto Lanzar Caña (Auto-Cast)",
        Description = "Lanza la caña automáticamente al agua si la tienes equipada.",
        Default = false,
        Callback = function(Value)
            _G.AutoCast = Value
            task.spawn(function()
                while _G.AutoCast do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            -- Intenta hacer clic virtual si tienes una caña
                            if tool and string.find(string.lower(tool.Name), "rod") then
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.1)
                                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end)
                    task.wait(2) -- Intenta cada 2 segundos
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("AutoReel", {
        Title = "Auto Capturar (Auto-Reel/Minigame)",
        Description = "Intenta completar el minijuego de pesca automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.AutoReel = Value
            task.spawn(function()
                while _G.AutoReel do
                    pcall(function()
                        -- Muchos juegos de pesca usan GUI para el minijuego, hacemos clics veloces como simulación genérica
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("👁️ Visuales Premium")

    Tabs.Specific:AddToggle("FullBright", {
        Title = "Brillo de las Profundidades (FullBright)",
        Description = "Quita la oscuridad e ilumina todo el océano para ver secretos.",
        Default = false,
        Callback = function(Value)
            _G.FullBright = Value
            local Lighting = game:GetService("Lighting")
            
            task.spawn(function()
                while _G.FullBright do
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000 -- Remueve la niebla del agua
                    task.wait(1)
                end
                
                if not _G.FullBright then
                    Lighting.ClockTime = 0
                    Lighting.FogEnd = 1000 -- Restaurar
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("NodeESP", {
        Title = "ESP Botín y Peces (Items ESP)",
        Description = "Rastrea cajas, minerales o peces especiales a tu alrededor.",
        Default = false,
        Callback = function(Value)
            _G.NodeESP = Value
            task.spawn(function()
                while _G.NodeESP do
                    pcall(function()
                        for _, v in workspace:GetDescendants() do
                            if v:IsA("Model") or v:IsA("BasePart") then
                                local name = string.lower(v.Name)
                                if string.find(name, "fish") or string.find(name, "crate") or string.find(name, "chest") or string.find(name, "ore") or string.find(name, "node") then
                                    if not v:FindFirstChild("onze_item_esp") then
                                        local h = Instance.new("Highlight")
                                        h.Name = "onze_item_esp"
                                        h.FillColor = Color3.fromRGB(0, 255, 100)
                                        h.OutlineColor = Color3.fromRGB(0, 50, 0)
                                        h.Parent = v
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                
                if not _G.NodeESP then
                    for _, v in workspace:GetDescendants() do
                        if v:FindFirstChild("onze_item_esp") then
                            v:FindFirstChild("onze_item_esp"):Destroy()
                        end
                    end
                end
            end)
        end
    })

    Tabs.Specific:AddSection("🎁 Utilidades VIP")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Premium (Marzo 2026)",
        Description = "Auto-canjea códigos ocultos para obtener Shards, Pociones de Suerte y Oxígeno.",
        Callback = function()
            local codes = {
                "FISHPOND",
                "MONKE",
                "LOVE",
                "BUGFIX01",
                "RELEASE"
            }
            
            Fluent:Notify({Title = "onzeHub VIP", Content = "Enviando 5 códigos VIP al servidor...", Duration = 3})
            
            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local remote = rs:FindFirstChild("Redeem", true) or rs:FindFirstChild("Codes", true) or rs:FindFirstChild("Code", true)
                
                if remote then
                    if remote:IsA("RemoteEvent") then
                        for _, code in codes do
                            pcall(function() remote:FireServer(code) end)
                            task.wait(0.3)
                        end
                    elseif remote:IsA("RemoteFunction") then
                        for _, code in codes do
                            pcall(function() remote:InvokeServer(code) end)
                            task.wait(0.3)
                        end
                    end
                    Fluent:Notify({Title = "onzeHub", Content = "¡Códigos enviados! Revisa tu inventario por pociones y Shards.", Duration = 4})
                else
                    Fluent:Notify({Title = "Aviso", Content = "La API cambió. Códigos copiados al portapapeles.", Duration = 4})
                    pcall(function() setclipboard(table.concat(codes, ", ")) end)
                end
            end)
        end
    })

end

return Module
