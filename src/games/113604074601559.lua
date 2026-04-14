local GameModule = {}

function GameModule.Load(Tabs, Window, Fluent, Options)
    local MainSection = Tabs.Specific:AddSection("🐝 Funciones de Colmena")
    
    -- [[ VARIABLES DE CONTROL ]]
    local getgenv = getgenv or function() return _G end
    local env = getgenv()
    env.AutoCollectHoney = false
    env.AutoSellHoney = false
    env.AutoBuyButtons = false
    
    -- TOGGLE: Auto Recolectar Miel
    MainSection:AddToggle("AutoCollectHoney", {
        Title = "Auto Recolectar Miel",
        Description = "Recolecta automáticamente la miel de tus abejas.",
        Default = false,
        Callback = function(state)
            env.AutoCollectHoney = state
            if state then
                task.spawn(function()
                    while env.AutoCollectHoney do
                        pcall(function()
                            -- [!] Remote de recolección (Usar SimpleSpy para confirmar)
                            -- game:GetService("ReplicatedStorage").Remotes.CollectHoney:FireServer()
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })

    -- TOGGLE: Auto Vender Miel
    MainSection:AddToggle("AutoSellHoney", {
        Title = "Auto Vender Miel",
        Description = "Vende automáticamente tu miel acumulada por dinero.",
        Default = false,
        Callback = function(state)
            env.AutoSellHoney = state
            if state then
                task.spawn(function()
                    while env.AutoSellHoney do
                        pcall(function()
                            -- [!] Remote de venta (Usar SimpleSpy)
                            -- game:GetService("ReplicatedStorage").Remotes.SellHoney:FireServer()
                        end)
                        task.wait(2)
                    end
                end)
            end
        end
    })

    -- TOGGLE: Auto Comprar Mejoras (Botones Tycoon)
    MainSection:AddToggle("AutoBuyButtonsBee", {
        Title = "Auto Comprar Mejoras",
        Description = "Compra automáticamente los botones de construcción.",
        Default = false,
        Callback = function(state)
            env.AutoBuyButtons = state
            if state then
                task.spawn(function()
                    while env.AutoBuyButtons do
                        pcall(function()
                            -- Lógica para pisar botones automáticamente (Simulado)
                            -- for _, button in ipairs(workspace.Tycoons.MyTycoon.Buttons:GetChildren()) do
                            --     if button:FindFirstChild("Head") then
                            --         firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, button.Head, 0)
                            --         task.wait(0.1)
                            --         firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, button.Head, 1)
                            --     end
                            -- end
                        end)
                        task.wait(3)
                    end
                end)
            end
        end
    })

    -- [[ UTILIDADES ]]
    local UtilSection = Tabs.Specific:AddSection("⚙️ Utilidades VIP")

    -- BOTÓN: Anti-AFK
    UtilSection:AddButton({
        Title = "Activar Anti-AFK",
        Description = "Evita que te desconecten por inactividad.",
        Callback = function()
            local VirtualUser = game:GetService("VirtualUser")
            game.Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
            
            Fluent:Notify({
                Title = "onzeHub",
                Content = "Anti-AFK activado con éxito.",
                Duration = 4
            })
        end
    })

    -- BOTÓN: Canjear Códigos
    UtilSection:AddButton({
        Title = "Canjear Códigos de Build A Beehive",
        Description = "Intenta canjear todos los códigos conocidos.",
        Callback = function()
            local Codes = {
                "E8CA45", 
                "QueenBeeWait", 
                "SummerEvent",
                "100KLIKES"
            }
            
            Fluent:Notify({Title = "onzeHub", Content = "Iniciando canjeo masivo...", Duration = 3})

            for _, code in ipairs(Codes) do
                pcall(function()
                    -- [!] Remote de canjeo real necesario
                    -- game:GetService("ReplicatedStorage").Remotes.RedeemCode:InvokeServer(code)
                    print("[onzeHub] Canjeando en Build A Beehive:", code)
                    task.wait(1)
                end)
            end

            Fluent:Notify({Title = "onzeHub", Content = "¡Códigos procesados!", Duration = 3})
        end
    })
end

return GameModule
