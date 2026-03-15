--[[
    onzeHub - Be Dino Module
    ID: 129907317028750
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Supervivencia")
    
    Tabs.Specific:AddToggle("AutoEat", {
        Title = "Auto Comer (Comida cercana)",
        Description = "Intenta comer comida automáticamente cuando estés cerca",
        Default = false,
        Callback = function(Value)
            _G.AutoEat = Value
            task.spawn(function()
                while _G.AutoEat do
                    pcall(function()
                        -- Lógica simple para detectar comida (Meat/Hatchling)
                        for _, v in pairs(workspace:GetChildren()) do
                            if v:FindFirstChild("Meat") or v.Name:find("Egg") then
                                local Distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                                if Distance < 15 then
                                    -- Aquí iría el evento de comer del juego
                                    print("Comida detectada cerca!")
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    Tabs.Specific:AddSection("Visuales")
    
    Tabs.Specific:AddToggle("PlayerESP", {
        Title = "ESP de Jugadores (Dinos)",
        Description = "Resalta a otros dinosaurios en el mapa",
        Default = false,
        Callback = function(Value)
            _G.DinoESP = Value
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    if Value then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "onzeHub_ESP"
                        Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        Highlight.Parent = player.Character
                    else
                        local h = player.Character:FindFirstChild("onzeHub_ESP")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    })

    Tabs.Specific:AddSection("Utilidades")
    
    Tabs.Specific:AddButton({
        Title = "Canjear todos los códigos",
        Description = "Intenta canjear códigos conocidos (XP, Gemas)",
        Callback = function()
            local Codes = {"DINORAW", "GEMS", "XPBOOST", "GROWTH"}
            for _, code in pairs(Codes) do
                -- Aquí iría el evento remoto de códigos del juego
                print("Intentando canjear código: " .. code)
            end
            Fluent:Notify({Title = "onzeHub", Content = "Proceso de códigos completado (Ver consola)", Duration = 3})
        end
    })
end

return Module
