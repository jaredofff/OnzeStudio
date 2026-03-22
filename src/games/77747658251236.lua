--[[
    onzeHub - Sailor Piece (Premium & Stealth)
    ID: 77747658251236
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información Navegante")

    Tabs.Specific:AddParagraph({
        Title = "Sailor Piece Premium v3",
        Content = "Script optimizado para farmear sin ser detectado. Incluye Anti-Staff y Teleport a islas."
    })

    -- Helpers
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local TweenService = game:GetService("TweenService")

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
    -- [[ SECCIÓN: ANTI-STAFF ]]
    -- =============================================
    Tabs.Specific:AddSection("Seguridad Avanzada")

    Tabs.Specific:AddToggle("SP_StaffDetector", {
        Title = "Detector de Moderadores",
        Description = "Te avisa si un staff entra y detiene todas las funciones automáticas.",
        Default = true,
        Callback = function(Value) _G.SP_StaffDetector = Value end
    })

    local function SafeCheck()
        if not _G.SP_StaffDetector then return true end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                -- Detección por ID baja o Tags comunes
                if p.UserId < 1000000 or p:GetRankInGroup(0) > 100 then 
                    _G.SP_KillAura = false
                    _G.SP_AutoFarm = false
                    Fluent:Notify({Title = "❗ STAFF DETECTADO", Content = "Pausando script por seguridad. Jugador: " .. p.Name, Duration = 10})
                    return false 
                end
            end
        end
        return true
    end

    -- =============================================
    -- [[ SECCIÓN: TELEPORT A ISLAS ]]
    -- =============================================
    Tabs.Specific:AddSection("Teletransportes del Mundo")

    local Islands = {
        ["Starter Island"] = Vector3.new(-395, 30, 260),
        ["Sailor Island"] = Vector3.new(1250, 40, -1800),
        ["Jungle Island"] = Vector3.new(-2500, 50, -450),
        ["Desert Island"] = Vector3.new(4200, 60, 1100),
        ["Snow Island"] = Vector3.new(-800, 70, 5500),
        ["Dungeon Island"] = Vector3.new(6500, 80, -3200),
        ["Boss Island"] = Vector3.new(-5000, 40, -4500),
        ["Shibuya Station"] = Vector3.new(8200, 90, 5800),
        ["Hueco Mundo"] = Vector3.new(-9500, 100, 2000),
        ["Judgement Island"] = Vector3.new(11000, 50, -1200)
    }

    local island_names = {}
    for name, _ in pairs(Islands) do table.insert(island_names, name) end
    table.sort(island_names)

    local IslandDropdown = Tabs.Specific:AddDropdown("SP_Islands", {
        Title = "Seleccionar Isla",
        Values = island_names,
        Default = "Starter Island",
        Callback = function(Value)
            _G.SelectedIsland = Value
        end
    })

    Tabs.Specific:AddButton({
        Title = "Viajar a Isla Seleccionada (Sigiloso)",
        Description = "Usa Tween para viajar de forma natural y evitar detecciones de TP.",
        Callback = function()
            local pos = Islands[_G.SelectedIsland]
            local hrp = getHRP()
            if pos and hrp then
                local dist = (hrp.Position - pos).Magnitude
                local info = TweenInfo.new(dist/120, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)})
                tween:Play()
                Fluent:Notify({Title = "Navegando", Content = "Viajando hacia " .. _G.SelectedIsland, Duration = 3})
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: COMBATE STEALTH ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate de Élite")

    Tabs.Specific:AddToggle("SP_KillAura", {
        Title = "Kill Aura Legítimo",
        Description = "Ataca a enemigos cercanos con intervalos humanos para evitar bans.",
        Default = false,
        Callback = function(Value) _G.SP_KillAura = Value end
    })

    Tabs.Specific:AddToggle("SP_AutoEquip", {
        Title = "Auto Equipar Arma",
        Default = true,
        Callback = function(Value) _G.SP_AutoEquip = Value end
    })

    -- Bucle único persistente (Más seguro y eficiente)
    task.spawn(function()
        while true do
            if _G.SP_KillAura and SafeCheck() then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    -- Equipar arma si no hay nada en la mano
                    if _G.SP_AutoEquip and not getChar():FindFirstChildOfClass("Tool") then
                        for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                            if t:IsA("Tool") then t.Parent = getChar(); break end
                        end
                    end

                    -- Buscar enemigos
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    for _, v in pairs(enemies:GetChildren()) do
                        if not _G.SP_KillAura then break end
                        local eHRP = v:FindFirstChild("HumanoidRootPart")
                        local eHum = v:FindFirstChild("Humanoid")
                        if eHRP and eHum and eHum.Health > 0 then
                            if (hrp.Position - eHRP.Position).Magnitude < 45 then
                                -- Click rítmico no robótico
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(math.random(6, 15) / 100)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end
                end)
            end
            task.wait(math.random(1, 3) / 10) -- Espera variable entre 0.1 y 0.3s
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades Pirata")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos (Todos)",
        Description = "Códigos de Marzo 2026 actualizados.",
        Callback = function()
            local codes = {
                "275KCCUOMG", "260KCCUINSANE", "245KCCUGETTINGTOOCRAZY", "230KCCUYALLTHEBEST",
                "TYFOR215KCCU", "THEBIG200KCCUTYSM", "OMG190KCCU", "INSANE180KCCU",
                "TYFOR170KCCUWOW", "EIDMUBARAK", "RESTARTSORRYYYY", "45KFOLLOWSTYY",
                "SMALLDELAYVERYSORRY", "BIGGESTUPDATENEXT", "ALTERUPDATE", "HUGEUPDATEW",
                "3SPECS", "BOSSRUSH", "VERYBIGUPDATESOON", "SINOFPRIDE"
            }
            Fluent:Notify({Title = "Sailor Piece", Content = "Canjeando códigos...", Duration = 3})
            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                for _, c in ipairs(codes) do
                    pcall(function()
                        local remote = rs:FindFirstChild("Code", true) or rs:FindFirstChild("Redeem", true)
                        if remote then
                            if remote:IsA("RemoteEvent") then remote:FireServer(c)
                            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(c) end
                        end
                    end)
                    task.wait(0.5)
                end
                Fluent:Notify({Title = "Sailor Piece", Content = "Proceso terminado.", Duration = 4})
            end)
        end
    })

    Tabs.Specific:AddToggle("SP_InfiniteGeppo", {
        Title = "Infinite Sky Jump",
        Default = false,
        Callback = function(Value) _G.SP_Geppo = Value end
    })

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.SP_Geppo then
            local hum = getHum()
            if hum then hum:ChangeState("Jumping") end
        end
    end)
end

return Module
