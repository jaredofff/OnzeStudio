local GameModule = {}

function GameModule.Load(Tabs, Window, Fluent, Options)
    local MainSection = Tabs.Specific:AddSection("🏭 Funciones de Tycoon")
    
    -- Variables de control globales (anti-crash)
    local getgenv = getgenv or function() return _G end
    local env = getgenv()
    env.AutoCollect = false
    env.AutoUnbox = false
    env.AutoBuy = false
    env.AutoRebirth = false
    
    -- Toggle: Auto Recolectar Drop / Dinero
    MainSection:AddToggle("AutoCollectUF", {
        Title = "Auto Recolectar Dinero", 
        Description = "Recoge automáticamente el dinero de tu fábrica.",
        Default = false,
        Callback = function(state)
            env.AutoCollect = state
            if state then
                task.spawn(function()
                    while env.AutoCollect do
                        pcall(function()
                            -- [!] NOTA PARA EL DESARROLLADOR: 
                            -- Debes usar SimpleSpy para encontrar el Remote real.
                            -- Ejemplo aproximado:
                            -- game:GetService("ReplicatedStorage").Remotes.Collect:FireServer()
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })

    -- Toggle: Auto Comprar Mejoras
    MainSection:AddToggle("AutoBuyUF", {
        Title = "Auto Comprar Mejoras (Botones Verdes)", 
        Description = "Pisa o compra automáticamente los botones de construcción.",
        Default = false,
        Callback = function(state)
            env.AutoBuy = state
            if state then
                task.spawn(function()
                    while env.AutoBuy do
                        pcall(function()
                            -- Lógica para tocar las partes (Tycoon Buttons)
                            -- Por ejemplo, iterar sobre los botones no comprados de tu base:
                            -- for _, button in ipairs(workspace.Tycoons.MiTycoon.Buttons:GetChildren()) do
                            --     firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, button.Head, 0)
                            --     task.wait(0.1)
                            --     firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, button.Head, 1)
                            -- end
                        end)
                        task.wait(3)
                    end
                end)
            end
        end
    })

    -- Toggle: Auto Unbox (Abrir cajas automáticamente)
    MainSection:AddToggle("AutoUnboxUF", {
        Title = "Auto Unbox (Abrir Cajas)", 
        Description = "Abre las máquinas/cajas automáticamente.",
        Default = false,
        Callback = function(state)
            env.AutoUnbox = state
            if state then
                task.spawn(function()
                    while env.AutoUnbox do
                        pcall(function()
                            -- [!] Remote real de unbox a colocar aquí:
                            -- game:GetService("ReplicatedStorage").Remotes.BuyBox:InvokeServer()
                        end)
                        task.wait(2) -- Un delay seguro para no ser kickeado por spam
                    end
                end)
            end
        end
    })

    -- Toggle: Auto Rebirth
    MainSection:AddToggle("AutoRebirthUF", {
        Title = "Auto Rebirth (Prestigio)", 
        Description = "Hace rebirth de forma automática al alcanzar el dinero.",
        Default = false,
        Callback = function(state)
            env.AutoRebirth = state
            if state then
                task.spawn(function()
                    while env.AutoRebirth do
                        pcall(function()
                            -- Remote de rebirth
                            -- game:GetService("ReplicatedStorage").Remotes.Rebirth:FireServer()
                        end)
                        task.wait(5)
                    end
                end)
            end
        end
    })

    -- Sección de utilidades
    local UtilSection = Tabs.Specific:AddSection("💸 Misceláneo")
    
    -- Botón: Anti-AFK
    UtilSection:AddButton({
        Title = "Activar Anti-AFK",
        Description = "Evita que Roblox te desconecte por inactividad (20 mins).",
        Callback = function()
            local VirtualUser = game:GetService("VirtualUser")
            game.Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
            
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "¡Activado! Ahora puedes dejar farmeando sin que te desconecte.",
                Duration = 4
            })
        end
    })

    -- Botón: Canjear Códigos
    UtilSection:AddButton({
        Title = "Canjear todos los códigos",
        Description = "Canjea los códigos activos descubiertos.",
        Callback = function()
            local Codes = {
                "1KLIKES",
                "100LIKES",
                "welcome"
            }
            
            Fluent:Notify({Title = "onzeHub", Content = "Canjeando códigos...", Duration = 2})

            for _, code in ipairs(Codes) do
                pcall(function()
                    -- [!] Función remota real necesaria aquí
                    -- game:GetService("ReplicatedStorage").Remotes.RedeemCode:InvokeServer(code)
                    print("[onzeHub] Intentando código: " .. code)
                    task.wait(0.5)
                end)
            end

            Fluent:Notify({Title = "onzeHub", Content = "¡Proceso de códigos finalizado!", Duration = 3})
        end
    })
end

return GameModule
