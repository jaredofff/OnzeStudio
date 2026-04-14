local GameModule = {}

function GameModule.Load(Tabs, Window, Fluent, Options)
    local MainSection = Tabs.Specific:AddSection("🧟 Combate y Loot")
    local ESPSection = Tabs.Specific:AddSection("👁️ Visuales (ESP)")
    local UtilSection = Tabs.Specific:AddSection("🛠️ Utilidades")
    
    local getgenv = getgenv or function() return _G end
    local env = getgenv()
    env.AutoLoot = false
    env.HitboxExpander = false
    env.ESPZombies = false
    env.ESPItems = false
    env.KillAura = false
    env.AntiKB = false
    env.CFSpeed = false
    
    -- [[ VAPE STYLE: KillAura ]]
    MainSection:AddToggle("KillAuraVape", {
        Title = "KillAura (Vape Style)", 
        Description = "Ataca a los zombies en un radio 360° automáticamente usndo el arma que tengas equipada.",
        Default = false,
        Callback = function(state)
            env.KillAura = state
            task.spawn(function()
                while env.KillAura do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local weapon = char:FindFirstChildOfClass("Tool")
                            if weapon and weapon:FindFirstChild("Handle") then
                                for _, v in pairs(workspace:GetDescendants()) do
                                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and (v.Name:lower():match("zombie") or v.Name:lower():match("infected")) then
                                        local targetHrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                                        if targetHrp and (targetHrp.Position - char.HumanoidRootPart.Position).Magnitude <= 18 then
                                            -- Simular el golpe físico usando firetouchinterest
                                            if firetouchinterest then
                                                firetouchinterest(weapon.Handle, targetHrp, 0)
                                                task.wait(0.01)
                                                firetouchinterest(weapon.Handle, targetHrp, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.12) -- Velocidad de ataque moderada
                end
            end)
        end
    })

    -- [[ VAPE STYLE: Velocity (Anti-Knockback) ]]
    MainSection:AddToggle("VelocityVape", {
        Title = "Velocity (Anti-Knockback)", 
        Description = "Los zombies ya no podrán empujarte hacia atrás al golpearte. Te quedas firme.",
        Default = false,
        Callback = function(state)
            env.AntiKB = state
            task.spawn(function()
                local rs = game:GetService("RunService")
                while env.AntiKB do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            -- Neutralizar la fuerza horizontal impuesta externa
                            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
                        end
                    end)
                    rs.RenderStepped:Wait()
                end
            end)
        end
    })

    -- Hitbox Expander para Zombies
    MainSection:AddToggle("ZombieHitbox", {
        Title = "Expandir Hitbox de Zombies", 
        Description = "Aumenta la cabeza de los zombies (Hitbox) para apuntar mucho más fácil a la cabeza.",
        Default = false,
        Callback = function(state)
            env.HitboxExpander = state
            task.spawn(function()
                while env.HitboxExpander do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            -- Buscar modelos que tengan humanoid (zombies)
                            if v:IsA("Model") and v:FindFirstChild("Humanoid") and (v.Name:lower():match("zombie") or v.Name:lower():match("infected")) then
                                local head = v:FindFirstChild("Head")
                                if head then
                                    head.Size = Vector3.new(4, 4, 4)
                                    head.Transparency = 0.6
                                    head.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end
    })

    -- Auto Recolectar (Loot Auto-Aura)
    MainSection:AddToggle("AutoCollectLoot", {
        Title = "Auto Loot / Recolectar", 
        Description = "Activa automáticamente los ProximityPrompts cercanos (Chatarra, Comida, Energía).",
        Default = false,
        Callback = function(state)
            env.AutoLoot = state
            task.spawn(function()
                while env.AutoLoot do
                    pcall(function()
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Buscar objetos con los que interactuar
                            for _, v in pairs(workspace:GetDescendants()) do
                                if v:IsA("ProximityPrompt") then
                                    local dist = (v.Parent.Position - hrp.Position).Magnitude
                                    if dist <= 12 then -- Rango configurado a 12 studs por seguridad
                                        fireproximityprompt(v, 1)
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    })

    -- Auto Generador (Alimentar o Defender la base simulado)
    MainSection:AddButton({
        Title = "Alimentar Base/Generador Activo",
        Description = "Si estás cerca, deposita los recursos requeridos automáticamente (Función Útil).",
        Callback = function()
            -- Placeholder para la invocación del RemoteEvent específico del juego
            Fluent:Notify({Title = "Base", Content = "Buscando interactuables cercanos del generador...", Duration = 2})
            -- Implementación típica:
            pcall(function()
                for _, vp in pairs(workspace:GetDescendants()) do
                    if vp:IsA("ProximityPrompt") and vp.ActionText:lower():match("deposit") or vp.ActionText:lower():match("feed") then
                        fireproximityprompt(vp)
                    end
                end
            end)
        end
    })

    -- ESP de Zombies
    ESPSection:AddToggle("ZombieESP", {
        Title = "ESP Zombies", 
        Description = "Muestra a los infectados a través de las paredes.",
        Default = false,
        Callback = function(state)
            env.ESPZombies = state
            task.spawn(function()
                while env.ESPZombies do
                    pcall(function()
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v:FindFirstChild("Humanoid") and (v.Name:lower():match("zombie") or v.Name:lower():match("infected")) then
                                if not v:FindFirstChild("oH_Z_ESP") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "oH_Z_ESP"
                                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                                    hl.OutlineColor = Color3.fromRGB(200, 200, 200)
                                    hl.Parent = v
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                
                -- Limpieza
                if not env.ESPZombies then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Highlight") and v.Name == "oH_Z_ESP" then
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    })

    -- ESP de Items Importantes (Loot)
    ESPSection:AddToggle("ItemESP", {
        Title = "ESP Botín/Recursos (Scrap, Food, etc.)", 
        Description = "Te muestra dónde encontrar materiales para tu base.",
        Default = false,
        Callback = function(state)
            env.ESPItems = state
            -- La lógica de ESP de items podría ser marcar todos los drop nodes del mapa
            task.spawn(function()
                while env.ESPItems do
                    pcall(function()
                        -- Iterar por los meshparts/partes que usualmente son el botín
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and (prompt.ActionText:lower():match("search") or prompt.ActionText:lower():match("pick")) then
                                local parent = prompt.Parent
                                if parent and not parent:FindFirstChild("oH_I_ESP") then
                                    local bil = Instance.new("BillboardGui")
                                    bil.Name = "oH_I_ESP"
                                    bil.Size = UDim2.new(0, 100, 0, 30)
                                    bil.AlwaysOnTop = true
                                    
                                    local txt = Instance.new("TextLabel")
                                    txt.Parent = bil
                                    txt.Size = UDim2.new(1,0,1,0)
                                    txt.Text = prompt.ActionText
                                    txt.TextColor3 = Color3.fromRGB(50, 255, 50)
                                    txt.BackgroundTransparency = 1
                                    txt.Font = Enum.Font.SourceSansBold
                                    txt.TextSize = 14
                                    
                                    bil.Parent = parent
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                
                if not env.ESPItems then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BillboardGui") and v.Name == "oH_I_ESP" then
                            v:Destroy()
                        end
                    end
                end
            end)
        end
    })

    -- FullBright (Visión Nocturna)
    UtilSection:AddButton({
        Title = "Visión Nocturna (Fullbright)",
        Description = "Ve todo claro de noche. Esencial para sobrevivir las oleadas en la oscuridad.",
        Callback = function()
            game.Lighting.Ambient = Color3.new(1, 1, 1)
            game.Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            game.Lighting.ColorShift_Top = Color3.new(1, 1, 1)
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
            game.Lighting.ClockTime = 12
            
            Fluent:Notify({Title = "onzeHub", Content = "Visión Nocturna Activada", Duration=3})
        end
    })



    -- [[ VAPE STYLE: CFrame Speed (Speedhack Indetectable) ]]
    UtilSection:AddToggle("CFSpeedVape", {
        Title = "CFrame Speed / Boost", 
        Description = "Acelera tus pasos de forma agresiva simulando pequeñas teletransportaciones hacia adelante.",
        Default = false,
        Callback = function(state)
            env.CFSpeed = state
            task.spawn(function()
                local rs = game:GetService("RunService")
                while env.CFSpeed do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                            -- Multiplicador de velocidad (Moverse fracciones extra por cada frame direccional)
                            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.6)
                        end
                    end)
                    rs.Heartbeat:Wait()
                end
            end)
        end
    })

    -- Infinite Jump / Anti-Gravity
    UtilSection:AddToggle("InfJump", {
        Title = "Saltos Infinitos", 
        Description = "Pulsa espacio en el aire para volar/escalar y escapar de las hordas.",
        Default = false,
        Callback = function(state)
            env.InfJump = state
            if state then
                game:GetService("UserInputService").JumpRequest:Connect(function()
                    if env.InfJump then
                        pcall(function()
                            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                        end)
                    end
                end)
            end
        end
    })
    
end

return GameModule
