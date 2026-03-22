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

    local function GetKLTarget()
        local hrp = getHRP()
        if not hrp then return nil end
        local t = nil
        local minDist = 2000
        
        -- Buscar en workspace.Enemies
        for _, v in pairs(workspace:FindFirstChild("Enemies") and workspace.Enemies:GetChildren() or workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local eHRP = v:FindFirstChild("HumanoidRootPart")
                if eHRP then
                    local dist = (hrp.Position - eHRP.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        t = v
                    end
                end
            end
        end
        return t
    end

    Tabs.Specific:AddToggle("KL_AutoFarm", {
        Title = "Auto Farm Level (Beta)",
        Description = "Teletransporta a los enemigos y los ataca automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.KL_AutoFarm = Value
            if not Value then
                local hrp = getHRP()
                if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            end
        end
    })

    -- Bucle único para evitar hilos fantasmas
    task.spawn(function()
        while true do
            if _G.KL_AutoFarm then
                pcall(function()
                    local target = GetKLTarget()
                    local hrp = getHRP()
                    if target and hrp and _G.KL_AutoFarm then
                        local eHRP = target:FindFirstChild("HumanoidRootPart")
                        if eHRP then
                            hrp.CFrame = eHRP.CFrame * CFrame.new(0, 7, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: COMBATE ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate Avanzado")

    Tabs.Specific:AddToggle("KL_KillAura", {
        Title = "Kill Aura Premium",
        Default = false,
        Callback = function(Value)
            _G.KL_KillAura = Value
        end
    })

    -- Bucle Kill Aura único
    task.spawn(function()
        while true do
            if _G.KL_KillAura then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    for _, v in pairs(workspace:FindFirstChild("Enemies") and workspace.Enemies:GetChildren() or {}) do
                        if not _G.KL_KillAura then break end
                        local eHRP = v:FindFirstChild("HumanoidRootPart")
                        if eHRP and (hrp.Position - eHRP.Position).Magnitude < 25 then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: VISUALES ]]
    -- =============================================
    Tabs.Specific:AddSection("Visuales (Premium)")

    Tabs.Specific:AddToggle("KL_FruitESP", {
        Title = "ESP de Frutas (Auto)",
        Default = false,
        Callback = function(Value)
            _G.KL_FruitESP = Value
            if not Value then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:FindFirstChild("onze_esp") then v:FindFirstChild("onze_esp"):Destroy() end
                end
            end
        end
    })

    task.spawn(function()
        while true do
            if _G.KL_FruitESP then
                pcall(function()
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
                end)
            end
            task.wait(4)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento VIP")

    Tabs.Specific:AddToggle("KL_InfJump", {
        Title = "Geppo Infinito",
        Default = false,
        Callback = function(Value)
            _G.KL_InfJump = Value
        end
    })

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.KL_InfJump then
            local hum = getHum()
            if hum then hum:ChangeState("Jumping") end
        end
    end)

    Tabs.Specific:AddToggle("KL_Noclip", {
        Title = "Noclip",
        Default = false,
        Callback = function(Value)
            _G.KL_Noclip = Value
        end
    })

    RunService.Stepped:Connect(function()
        if _G.KL_Noclip and getChar() then
            for _, v in pairs(getChar():GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades Pirata")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos (Todos)",
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
