--[[
    onzeHub - Sailor Piece
    ID: 77747658251236
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información Navegante")

    Tabs.Specific:AddParagraph({
        Title = "Sailor Piece Premium",
        Content = "Script optimizado para Sailor Piece. Incluye Kill Aura, Teletransportes y utilidades de reroll."
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

    -- =============================================
    -- [[ SECCIÓN: COMBATE ]]
    -- =============================================
    Tabs.Specific:AddSection("Combate")

    Tabs.Specific:AddToggle("SP_KillAura", {
        Title = "Kill Aura (Solo Cerca)",
        Description = "Ataca automáticamente a los enemigos que estén a menos de 40 studs.",
        Default = false,
        Callback = function(Value)
            _G.SP_KillAura = Value
        end
    })

    -- Bucle único para Kill Aura
    task.spawn(function()
        while true do
            if _G.SP_KillAura then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    local enemies = workspace:FindFirstChild("Enemies") or workspace
                    for _, v in pairs(enemies:GetChildren()) do
                        if not _G.SP_KillAura then break end
                        local eHRP = v:FindFirstChild("HumanoidRootPart")
                        local eHum = v:FindFirstChild("Humanoid")
                        if eHRP and eHum and eHum.Health > 0 then
                            local dist = (hrp.Position - eHRP.Position).Magnitude
                            if dist < 40 then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end
                        end
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: TELEPORT ]]
    -- =============================================
    Tabs.Specific:AddSection("Teletransportes")

    local function GetClosestSPEnemy()
        local hrp = getHRP()
        if not hrp then return nil end
        local target = nil
        local minDist = 5000
        local enemies = workspace:FindFirstChild("Enemies") or workspace
        for _, v in pairs(enemies:GetChildren()) do
            local eHRP = v:FindFirstChild("HumanoidRootPart")
            if eHRP and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local dist = (hrp.Position - eHRP.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = v
                end
            end
        end
        return target
    end

    Tabs.Specific:AddButton({
        Title = "Teleport al Enemigo más cercano",
        Description = "Te lleva instantáneamente frente a un enemigo para pelear.",
        Callback = function()
            local target = GetClosestSPEnemy()
            local hrp = getHRP()
            if target and hrp then
                local eHRP = target:FindFirstChild("HumanoidRootPart")
                if eHRP then
                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, 5, 2)
                    Fluent:Notify({Title = "Sailor Piece", Content = "✓ Teletransportado a: " .. target.Name, Duration = 2})
                end
            else
                Fluent:Notify({Title = "Sailor Piece", Content = "No se encontraron enemigos cerca.", Duration = 2})
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades Pirata")

    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Activos (Marzo 2026)",
        Description = "Canjea +20 códigos de rewards masivos ($ Cash, Gems, Rerolls).",
        Callback = function()
            local codes = {
                "275KCCUOMG", "260KCCUINSANE", "245KCCUGETTINGTOOCRAZY", "230KCCUYALLTHEBEST",
                "TYFOR215KCCU", "THEBIG200KCCUTYSM", "OMG190KCCU", "INSANE180KCCU",
                "TYFOR170KCCUWOW", "EIDMUBARAK", "RESTARTSORRYYYY", "45KFOLLOWSTYY",
                "SMALLDELAYVERYSORRY", "BIGGESTUPDATENEXT", "ALTERUPDATE", "HUGEUPDATEW",
                "3SPECS", "BOSSRUSH", "VERYBIGUPDATESOON", "SINOFPRIDE"
            }
            Fluent:Notify({Title = "Sailor Piece", Content = "Iniciando canje de códigos...", Duration = 5})
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
        Callback = function(Value)
            _G.SP_Geppo = Value
        end
    })

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.SP_Geppo then
            local char = getChar()
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end)

end

return Module
