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
        Title = "Auto Hit / Swing Avanzado",
        Description = "Golpea automáticamente. Mejorado para detectar el 'volante' (shuttlecock).",
        Default = false,
        Callback = function(Value)
            _G.AutoSwing = Value
            task.spawn(function()
                local targetBall = nil
                local lastSearch = 0
                
                while _G.AutoSwing do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            
                            if not targetBall or not targetBall.Parent or (tick() - lastSearch > 2) then
                                lastSearch = tick()
                                targetBall = nil
                                
                                for _, v in pairs(workspace:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        local n = string.lower(v.Name)
                                        if string.find(n, "ball") or string.find(n, "shuttle") or string.find(n, "birdie") or string.find(n, "tennis") then
                                            targetBall = v
                                            break
                                        end
                                    end
                                end
                            end
                            
                            if targetBall and targetBall.Parent then
                                local dist = (char.HumanoidRootPart.Position - targetBall.Position).Magnitude
                                if dist < 25 then -- Distancia aumentada
                                    -- Utilizar VirtualInputManager para clics simulados (100% compatible)
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    task.wait(0.05)
                                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                    task.wait(0.4) -- Cooldown
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
        Title = "Expandir Hitbox del Objeto",
        Description = "Hace que el volante/pelota sea gigante en tu pantalla.",
        Default = false,
        Callback = function(Value)
            _G.ExpandBall = Value
            task.spawn(function()
                while _G.ExpandBall do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local n = string.lower(v.Name)
                                if string.find(n, "ball") or string.find(n, "shuttle") or string.find(n, "birdie") or string.find(n, "tennis") then
                                    v.Size = Vector3.new(15, 15, 15)
                                    v.Transparency = 0.5
                                    v.CanCollide = false
                                end
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
        Title = "ESP del Volante/Pelota",
        Default = false,
        Callback = function(Value)
            _G.BallESP = Value
            task.spawn(function()
                while _G.BallESP do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local n = string.lower(v.Name)
                                if string.find(n, "ball") or string.find(n, "shuttle") or string.find(n, "birdie") or string.find(n, "tennis") then
                                    if not v:FindFirstChild("onze_ball_esp") then
                                        local h = Instance.new("Highlight")
                                        h.Name = "onze_ball_esp"
                                        h.FillColor = Color3.fromRGB(255, 255, 0)
                                        h.OutlineColor = Color3.fromRGB(255, 0, 0)
                                        h.Parent = v
                                    end
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

    -- [[ UTILIDADES ]]
    Tabs.Specific:AddSection("Utilidades")
    
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Activos (Yen/Spins)",
        Description = "Intenta canjear automáticamente todos los códigos conocidos del juego.",
        Callback = function()
            local codes = {
                "ESLASGIFT", "PAWFEST", "NEWSHUTTLE", "REDENVELOPE", "UPDATE15",
                "FLEXURPACK", "UPDATE13", "MERRYCHRISTMAS", "SorryRanked", "BIGRANKED",
                "UPDATEONE", "NOWAYFIFTYK", "mistaworldwide", "USEMATCHMAKING",
                "SL3EPY", "FREEADMIN", "UPDATE14V1", "COMPETE", "UPDATE14", "300MVISITS",
                "UPDATE13V1", "RACKETSEEKER", "UPDATE12", "REFINE"
            }
            
            Fluent:Notify({Title = "onzeHub", Content = "Procesando " .. #codes .. " códigos...", Duration = 3})
            
            -- Los juegos de Roblox generalmente usan un RemoteEvent o Function para los códigos.
            -- Por seguridad, podemos intentar buscar RemoteEvents comunes si no conocemos el path exacto.
            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local remote = rs:FindFirstChild("RedeemCode", true) or rs:FindFirstChild("Codes", true)
                
                if remote and remote:IsA("RemoteEvent") then
                    for _, code in ipairs(codes) do
                        remote:FireServer(code)
                        task.wait(0.2)
                    end
                    Fluent:Notify({Title = "onzeHub", Content = "Códigos enviados.", Duration = 3})
                elseif remote and remote:IsA("RemoteFunction") then
                    for _, code in ipairs(codes) do
                        pcall(function() 
                            remote:InvokeServer(code) 
                        end)
                        task.wait(0.2)
                    end
                    Fluent:Notify({Title = "onzeHub", Content = "Códigos enviados.", Duration = 3})
                else
                    -- Fallback: Si no se encuentra el remote, al menos copiamos los códigos al portapapeles
                    Fluent:Notify({Title = "onzeHub", Content = "No se encontró el Remote de Códigos automático.", Duration = 4})
                    -- print("Códigos: ", table.concat(codes, ", "))
                end
            end)
        end
    })
end

return Module
