--[[
    onzeHub - Sailor Piece (Ultimate Stealth & Survival)
    ID: 77747658251236
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información Navegante")

    Tabs.Specific:AddParagraph({
        Title = "Sailor Piece VIP Survival",
        Content = "Script optimizado para no recibir daño y farmear a distancia segura."
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
        Default = true,
        Callback = function(v) _G.SP_StaffDetector = v end
    })

    local function SafeCheck()
        if not _G.SP_StaffDetector then return true end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.UserId < 1000000 or p:GetRankInGroup(0) > 100) then 
                _G.SP_KillAura = false
                _G.SP_Hitbox = false
                _G.SP_SafeMode = false
                return false 
            end
        end
        return true
    end

    -- =============================================
    -- [[ SECCIÓN: COMBATE SEGURO ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate & Supervivencia")

    Tabs.Specific:AddToggle("SP_SafeMode", {
        Title = "Modo Seguro (Flotar)",
        Description = "Te mantiene suspendido en el aire sobre los enemigos para que no te peguen mientras usas el Hitbox Expander.",
        Default = false,
        Callback = function(v) _G.SP_SafeMode = v end
    })

    Tabs.Specific:AddToggle("SP_KillAura", {
        Title = "Kill Aura",
        Default = false,
        Callback = function(v) _G.SP_KillAura = v end
    })

    Tabs.Specific:AddToggle("SP_Hitbox", {
        Title = "Hitbox Expander (Alcance)",
        Default = false,
        Callback = function(v) _G.SP_Hitbox = v end
    })

    Tabs.Specific:AddSlider("SP_HitboxSize", {
        Title = "Tamaño Alcance",
        Default = 15, Min = 5, Max = 50, Rounding = 1,
        Callback = function(v) _G.SP_HitboxSize = v end
    })

    -- Bucle de Combate y Supervivencia
    task.spawn(function()
        while true do
            if SafeCheck() then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    local closest = nil
                    local minDist = 2000
                    
                    for _, v in pairs(enemies:GetChildren()) do
                        local eHRP = v:FindFirstChild("HumanoidRootPart")
                        local eHum = v:FindFirstChild("Humanoid")
                        
                        if eHRP and eHum and eHum.Health > 0 then
                            local dist = (hrp.Position - eHRP.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closest = v
                            end
                            
                            -- Aplicar Hitbox si está cerca
                            if _G.SP_Hitbox and dist < 200 then
                                eHRP.Size = Vector3.new(_G.SP_HitboxSize or 15, _G.SP_HitboxSize or 15, _G.SP_HitboxSize or 15)
                                eHRP.Transparency = 0.7
                                eHRP.CanCollide = false
                            end

                            -- Atacar
                            if _G.SP_KillAura and dist < 70 then
                                -- Click rítmico no robótico (Usando posición actual del mouse para no bloquear el Hub)
                                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                                task.wait(math.random(5, 10) / 100)
                                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
                            end
                        end
                    end
                    
                    -- Si SafeMode está activo, flotar sobre el mob más cercano
                    if _G.SP_SafeMode and closest and closest:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: AUTO STATS ]]
    -- =============================================
    Tabs.Specific:AddSection("Atributos (Auto Stats)")

    Tabs.Specific:AddToggle("SP_AutoStat", {
        Title = "Auto Subir Stats",
        Default = false,
        Callback = function(v) _G.SP_AutoStat = v end
    })

    Tabs.Specific:AddDropdown("SP_StatSelect", {
        Title = "Priorizar Stat:",
        Values = {"Defense", "Weapon", "Power"},
        Default = "Defense",
        Callback = function(v) _G.SP_StatTarget = v end
    })

    task.spawn(function()
        while true do
            if _G.SP_AutoStat then
                -- Sailor Piece suele tener eventos de stats en ReplicatedStorage
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Stats", true) or game:GetService("ReplicatedStorage"):FindFirstChild("AddStats", true)
                    if remote then
                        remote:FireServer(_G.SP_StatTarget or "Defense", 1)
                    end
                end)
            end
            task.wait(0.5)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: NAVEGACIÓN ]]
    -- =============================================
    Tabs.Specific:AddSection("Navegación & Islas")

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

    Tabs.Specific:AddDropdown("SP_Islands", {Title = "Seleccionar Isla", Values = island_names, Default = "Starter Island (0)", Callback = function(v) _G.SelectedIsland = v end})

    Tabs.Specific:AddButton({
        Title = "Viajar Sigilosamente",
        Callback = function()
            local pos = Islands[_G.SelectedIsland]
            local hrp = getHRP()
            if pos and hrp then
                local info = TweenInfo.new((hrp.Position - pos).Magnitude/150, Enum.EasingStyle.Linear)
                TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)}):Play()
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento VIP")

    Tabs.Specific:AddToggle("SP_InfiniteGeppo", {Title = "Salto Infinito", Default = false, Callback = function(v) _G.SP_Geppo = v end})
    Tabs.Specific:AddToggle("SP_Noclip", {Title = "Noclip", Default = false, Callback = function(v) _G.SP_Noclip = v end})

    RunService.Stepped:Connect(function()
        if _G.SP_Noclip and getChar() then
            for _, v in pairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.SP_Geppo then if getHum() then getHum():ChangeState("Jumping") end end
    end)
end

return Module
