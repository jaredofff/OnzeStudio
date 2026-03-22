--[[
    onzeHub - King Legacy (Premium)
    ID: 4520749081
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información Premium")

    Tabs.Specific:AddParagraph({
        Title = "King Legacy VIP",
        Content = "Script avanzado de onzeHub. Incluye Autofarm, Kill Aura mejorado y Teletransportes. ¡Usa con discreción!"
    })

    -- Helpers
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local function getChar() return LocalPlayer.Character end
    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function getHum()
        local c = getChar()
        return c and c:FindFirstChild("Humanoid")
    end

    -- =============================================
    -- [[ SECCIÓN: AUTOFARM ]]
    -- =============================================
    Tabs.Specific:AddSection("Auto Farm")

    Tabs.Specific:AddToggle("KL_AutoFarm", {
        Title = "Auto Farm Level (Beta)",
        Description = "Teletransporta a los enemigos y los ataca automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.KL_AutoFarm = Value
            task.spawn(function()
                while _G.KL_AutoFarm do
                    local success, err = pcall(function()
                        if not _G.KL_AutoFarm then return end
                        local hrp = getHRP()
                        if not hrp then return end
                        
                        -- Buscar enemigo más cercano o por misión
                        local target = nil
                        local minDist = 1500 -- Rango de búsqueda
                        
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if not _G.KL_AutoFarm then break end
                            local eHRP = v:FindFirstChild("HumanoidRootPart")
                            local eHum = v:FindFirstChild("Humanoid")
                            if eHRP and eHum and eHum.Health > 0 then
                                local dist = (hrp.Position - eHRP.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    target = v
                                end
                            end
                        end
                        
                        if target and _G.KL_AutoFarm then
                            local eHRP = target.HumanoidRootPart
                            -- TP detrás/arriba del enemigo
                            hrp.CFrame = eHRP.CFrame * CFrame.new(0, 5, 2)
                            
                            -- Atacar
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end)
                    if not success then warn("KL AutoFarm Error: " .. tostring(err)) end
                    task.wait(0.2)
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: COMBATE ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate Avanzado")

    Tabs.Specific:AddToggle("KL_KillAura", {
        Title = "Kill Aura Premium",
        Description = "Ataca a todo lo que esté cerca automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.KL_KillAura = Value
            task.spawn(function()
                while _G.KL_KillAura do
                    pcall(function()
                        if not _G.KL_KillAura then return end
                        local hrp = getHRP()
                        if not hrp then return end
                        
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if not _G.KL_KillAura then break end
                            local eHRP = v:FindFirstChild("HumanoidRootPart")
                            if eHRP and (hrp.Position - eHRP.Position).Magnitude < 25 then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.01)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: VISUALES ]]
    -- =============================================
    Tabs.Specific:AddSection("Visuales (Premium)")

    Tabs.Specific:AddToggle("KL_FruitESP", {
        Title = "ESP de Frutas (Auto)",
        Description = "Muestra y avisa cuando aparece una fruta.",
        Default = false,
        Callback = function(Value)
            _G.KL_FruitESP = Value
            task.spawn(function()
                while _G.KL_FruitESP do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and string.find(string.lower(v.Name), "fruit") then
                            if not v:FindFirstChild("onze_esp") then
                                local h = Instance.new("Highlight")
                                h.Name = "onze_esp"
                                h.FillColor = Color3.fromRGB(255, 0, 100)
                                h.Parent = v
                                Fluent:Notify({Title = "onzeHub", Content = "¡Fruta detectada: " .. v.Name .. "!", Duration = 5})
                            end
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento VIP")

    Tabs.Specific:AddToggle("KL_InfJump", {
        Title = "Geppo Infinito (Sky Jump)",
        Description = "Salta en el aire sin límites.",
        Default = false,
        Callback = function(Value)
            _G.KL_InfJump = Value
            LocalPlayer.CharacterAdded:Connect(function() -- Re-conectar al morir
                if _G.KL_InfJump then
                    game:GetService("UserInputService").JumpRequest:Connect(function()
                        if _G.KL_InfJump then getHum():ChangeState("Jumping") end
                    end)
                end
            end)
            -- Inicial
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.KL_InfJump then 
                    local hum = getHum()
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        end
    })

    Tabs.Specific:AddToggle("KL_Noclip", {
        Title = "Noclip (Atravesar Paredes)",
        Default = false,
        Callback = function(Value)
            _G.KL_Noclip = Value
            if Value then
                _G.KL_NoclipConn = RunService.Stepped:Connect(function()
                    if _G.KL_Noclip and getChar() then
                        for _, v in pairs(getChar():GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    else
                        if _G.KL_NoclipConn then 
                            _G.KL_NoclipConn:Disconnect() 
                            _G.KL_NoclipConn = nil
                        end
                    end
                end)
            else
                if _G.KL_NoclipConn then 
                    _G.KL_NoclipConn:Disconnect() 
                    _G.KL_NoclipConn = nil
                end
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades Pirata")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos (Todos)",
        Description = "Canjea automáticamente los mejores códigos de Marzo 2026.",
        Callback = function()
            local codes = {
                "FIXEDBUG1003", "Serpent10", "FreePterSpin", "Update10Release",
                "SKGames", "RainbowDragon", "DragonColorRefund", "WELCOMETOKINGLEGACY",
                "<3LEEPUNGG", "DinoxLive", "Peodiz", "FREESTATSRESET", "2MFAV"
            }
            Fluent:Notify({Title = "King Legacy", Content = "Iniciando canje automático...", Duration = 3})
            task.spawn(function()
                for _, c in ipairs(codes) do
                    pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("AllCode", true)
                        if remote then remote:FireServer(c) end
                    end)
                    task.wait(0.5)
                end
                Fluent:Notify({Title = "King Legacy", Content = "Proceso terminado.", Duration = 3})
            end)
        end
    })

    Tabs.Specific:AddButton({
        Title = "TP a la Fruta más cercana",
        Callback = function()
            local hrp = getHRP()
            local found = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.find(string.lower(v.Name), "fruit") then
                    local p = v:FindFirstChildWhichIsA("BasePart")
                    if p then
                        hrp.CFrame = p.CFrame + Vector3.new(0, 3, 0)
                        found = true
                        break
                    end
                end
            end
            if not found then Fluent:Notify({Title = "onzeHub", Content = "No hay frutas en el servidor.", Duration = 3}) end
        end
    })

end

return Module
