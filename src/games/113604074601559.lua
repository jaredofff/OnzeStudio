local GameModule = {}

function GameModule.Load(Tabs, Window, Fluent, Options)
    local CodeSection = Tabs.Specific:AddSection("💸 Auto-Canjeador de Códigos")
    
    CodeSection:AddButton({
        Title = "Canjear códigos de Build A Beehive",
        Description = "Intenta canjear automáticamente el código E8CA45",
        Callback = function()
            local ActivesCodes = {
                "E8CA45", -- Activo (Otorga 500 Cash)
                
                -- === CÓDIGOS EXPIRADOS (Dejados aquí por si los reactivan) ===
                -- "QueenBeeWait", 
                -- "SummerEvent",
                -- "100KLIKES"
            }
            
            Fluent:Notify({
                Title = "onzeHub | Codes",
                Content = "Iniciando el canjeo automático...",
                Duration = 3
            })

            local successCount = 0

            for _, code in ipairs(ActivesCodes) do
                pcall(function()
                    -- NOTA: Como no sabemos la ruta exacta del RemoteEvent del juego Build A Beehive,
                    -- aquí tendrías que ponerlo cuando lo averigües con SimpleSpy.
                    -- Ejemplo: game:GetService("ReplicatedStorage").Remotes.RedeemCode:InvokeServer(code)
                    
                    print("[onzeHub] Intentando canjear:", code)
                    successCount = successCount + 1
                    task.wait(0.5)
                end)
            end

            Fluent:Notify({
                Title = "onzeHub | Completado",
                Content = "Se procesaron " .. tostring(successCount) .. " códigos.",
                Duration = 5
            })
        end
    })
end

return GameModule
