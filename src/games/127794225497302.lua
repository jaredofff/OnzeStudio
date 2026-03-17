--[[
    onzeHub - Abyss
    ID: 127794225497302
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información")
    
    Tabs.Specific:AddParagraph({
        Title = "Abyss",
        Content = "Bienvenido a Abyss. Selecciona las funciones que deseas activar en este juego oscuro."
    })
    
    Tabs.Specific:AddSection("Ventajas de Juego")

    -- Ejemplo: Brillo Máximo (FullBright) muy útil en juegos oscuros como Abyss
    Tabs.Specific:AddToggle("FullBright", {
        Title = "Brillo al Máximo (FullBright)",
        Description = "Ilumina todo el mapa para ver en la oscuridad.",
        Default = false,
        Callback = function(Value)
            _G.FullBright = Value
            local Lighting = game:GetService("Lighting")
            
            task.spawn(function()
                while _G.FullBright do
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                    Lighting.ClockTime = 14 -- Mediodía
                    task.wait(1)
                end
                
                -- Si se apaga, no sabemos el ambiente original exacto, pero podemos ponerlo de noche
                if not _G.FullBright then
                    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                    Lighting.ClockTime = 0
                end
            end)
        end
    })

end

return Module
