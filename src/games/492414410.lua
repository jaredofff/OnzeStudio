--[[
    onzeHub - Brookhaven Module
    ID: 492414410
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Teletransportes")
    
    Tabs.Specific:AddDropdown("BrookTeleport", {
        Title = "Lugares Importantes",
        Values = {"Banco", "Gasolinera", "Hospital", "Estación de Policía", "Ayuntamiento", "Lago"},
        Multi = false,
        Default = 1,
        Callback = function(Value)
            local Locations = {
                ["Banco"] = Vector3.new(-333, 24, 60),
                ["Gasolinera"] = Vector3.new(-380, 24, 210),
                ["Hospital"] = Vector3.new(-250, 24, -135),
                ["Estación de Policía"] = Vector3.new(-245, 24, 30),
                ["Ayuntamiento"] = Vector3.new(-180, 24, -10),
                ["Lago"] = Vector3.new(-500, 24, 500)
            }
            local Pos = Locations[Value]
            if Pos then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Pos)
            end
        end
    })

    Tabs.Specific:AddSection("Economía y Robos")
    
    Tabs.Specific:AddButton({
        Title = "Ir a la Caja Fuerte (Banco)",
        Description = "Te teletransporta directamente frente a la caja",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-480, 23, 102)
            Fluent:Notify({Title = "onzeHub", Content = "Usa el C4 para abrir la caja", Duration = 3})
        end
    })

    Tabs.Specific:AddSection("Avatar y Troll")
    
    Tabs.Specific:AddSlider("SizeSlider", {
        Title = "Tamaño del Personaje",
        Description = "Ajusta qué tan grande o pequeño eres (Visual)",
        Default = 1,
        Min = 0.3,
        Max = 5,
        Rounding = 1,
        Callback = function(Value)
            local Hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Hum then
                local BodyWidth = Hum:FindFirstChild("BodyWidthScale")
                local BodyHeight = Hum:FindFirstChild("BodyHeightScale")
                local BodyDepth = Hum:FindFirstChild("BodyDepthScale")
                local HeadScale = Hum:FindFirstChild("HeadScale")
                
                if BodyWidth then BodyWidth.Value = Value end
                if BodyHeight then BodyHeight.Value = Value end
                if BodyDepth then BodyDepth.Value = Value end
                if HeadScale then HeadScale.Value = Value end
            end
        end
    })

    Tabs.Specific:AddButton({
        Title = "Hacerte Pequeño (Sigilo)",
        Callback = function()
            Options.SizeSlider:SetValue(0.3)
        end
    })
end

return Module
