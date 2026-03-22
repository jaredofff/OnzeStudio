--[[
    onzeHub - Sailor Piece (Ultimate Stealth & Farm)
    ID: 77747658251236
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Guía de Leveo Rápido")

    Tabs.Specific:AddParagraph({
        Title = "Consejos para subir de nivel:",
        Content = "1. Usa el 'Hitbox Expander' para pegar de lejos.\n2. Ve a la isla de tu nivel (usa el TP de Islas).\n3. Activa 'Kill Aura' y quédate en el centro de los mobs.\n4. Reclama códigos para obtener Gemas y Rerolls."
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
    Tabs.Specific:AddSection("Seguridad (Anti-Staff)")

    Tabs.Specific:AddToggle("SP_StaffDetector", {
        Title = "Staff Detector",
        Description = "Detiene todo si un moderador entra.",
        Default = true,
        Callback = function(v) _G.SP_StaffDetector = v end
    })

    local function SafeCheck()
        if not _G.SP_StaffDetector then return true end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.UserId < 1000000 or p:GetRankInGroup(0) > 100) then 
                _G.SP_KillAura = false
                _G.SP_Hitbox = false
                return false 
            end
        end
        return true
    end

    -- =============================================
    -- [[ SECCIÓN: COMBATE & DISTANCIA ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate & Alcance")

    Tabs.Specific:AddToggle("SP_KillAura", {
        Title = "Kill Aura Pro",
        Default = false,
        Callback = function(v) _G.SP_KillAura = v end
    })

    Tabs.Specific:AddToggle("SP_Hitbox", {
        Title = "Hitbox Expander (Alcance)",
        Description = "Hace que los enemigos tengan un hitbox gigante para pegarles de lejos.",
        Default = false,
        Callback = function(v) _G.SP_Hitbox = v end
    })

    Tabs.Specific:AddSlider("SP_HitboxSize", {
        Title = "Tamaño del Hitbox",
        Default = 15,
        Min = 5,
        Max = 50,
        Rounding = 1,
        Callback = function(v) _G.SP_HitboxSize = v end
    })

    -- Bucle de Combate y Hitbox
    task.spawn(function()
        while true do
            if SafeCheck() then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    for _, v in pairs(enemies:GetChildren()) do
                        local eHRP = v:FindFirstChild("HumanoidRootPart")
                        local eHum = v:FindFirstChild("Humanoid")
                        
                        if eHRP and eHum and eHum.Health > 0 then
                            -- Hitbox Expander
                            if _G.SP_Hitbox then
                                eHRP.Size = Vector3.new(_G.SP_HitboxSize or 15, _G.SP_HitboxSize or 15, _G.SP_HitboxSize or 15)
                                eHRP.Transparency = 0.7
                                eHRP.CanCollide = false
                            else
                                eHRP.Size = Vector3.new(2, 2, 1)
                                eHRP.Transparency = 1
                            end

                            -- Kill Aura (Afectado por distancia)
                            if _G.SP_KillAura then
                                local dist = (hrp.Position - eHRP.Position).Magnitude
                                if dist < 60 then -- Distancia aumentada para aprovechar hitbox
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    task.wait(math.random(5, 10) / 100)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: TELEPORT ISLAS ]]
    -- =============================================
    Tabs.Specific:AddSection("Navegación (Teleport)")

    local Islands = {
        ["Starter Island (0)"] = Vector3.new(-395, 30, 260),
        ["Sailor Island (0)"] = Vector3.new(1250, 40, -1800),
        ["Jungle Island (250)"] = Vector3.new(-2500, 50, -450),
        ["Desert Island (750)"] = Vector3.new(4200, 60, 1100),
        ["Snow Island (1500)"] = Vector3.new(-800, 70, 5500),
        ["Dungeon Island (1000)"] = Vector3.new(6500, 80, -3200),
        ["Shibuya Station (3000)"] = Vector3.new(8200, 90, 5800),
        ["Hueco Mundo (5000)"] = Vector3.new(-9500, 100, 2000),
        ["Judgement Island (7500)"] = Vector3.new(11000, 50, -1200)
    }

    local island_names = {}
    for name, _ in pairs(Islands) do table.insert(island_names, name) end
    table.sort(island_names)

    Tabs.Specific:AddDropdown("SP_Islands", {
        Title = "Viajar a:",
        Values = island_names,
        Default = "Starter Island (0)",
        Callback = function(v) _G.SelectedIsland = v end
    })

    Tabs.Specific:AddButton({
        Title = "Volar hacia Isla",
        Callback = function()
            local pos = Islands[_G.SelectedIsland]
            local hrp = getHRP()
            if pos and hrp then
                local dist = (hrp.Position - pos).Magnitude
                local info = TweenInfo.new(dist/150, Enum.EasingStyle.Linear)
                TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)}):Play()
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Extras")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos (X2 EXP/GEMS)",
        Callback = function()
            local codes = {"275KCCUOMG", "260KCCUINSANE", "245KCCUGETTINGTOOCRAZY", "230KCCUYALLTHEBEST", "RESTARTSORRYYYY", "HUGEUPDATEW"}
            for _, c in ipairs(codes) do
                pcall(function() game:GetService("ReplicatedStorage").Code:FireServer(c) end)
                task.wait(0.3)
            end
            Fluent:Notify({Title = "onzeHub", Content = "Códigos canjeados.", Duration = 3})
        end
    })

    Tabs.Specific:AddToggle("SP_InfiniteGeppo", {
        Title = "Salto Infinito",
        Default = false,
        Callback = function(v) _G.SP_Geppo = v end
    })

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.SP_Geppo then
            local hum = getHum()
            if hum then hum:ChangeState("Jumping") end
        end
    end)
end

return Module
