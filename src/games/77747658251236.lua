--[[
    onzeHub - Sailor Piece
    ID: 77747658251236
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información Navegante")

    Tabs.Specific:AddParagraph({
        Title = "Sailor Piece Premium",
        Content = "Script optimizado para Sailor Piece. Incluye Autofarm, Kill Aura y utilidades de reroll."
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
    -- [[ SECCIÓN: AUTOFARM ]]
    -- =============================================
    Tabs.Specific:AddSection("Auto Farm")

    Tabs.Specific:AddToggle("SP_AutoFarm", {
        Title = "Auto Farm (Enemigos)",
        Description = "Ataca y farmea a los enemigos automáticamente.",
        Default = false,
        Callback = function(Value)
            _G.SP_AutoFarm = Value
            task.spawn(function()
                while _G.SP_AutoFarm do
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end
                        
                        -- En Sailor Piece los enemigos suelen estar en workspace.Enemies o similar
                        local enemies = workspace:FindFirstChild("Enemies") or workspace
                        for _, v in pairs(enemies:GetChildren()) do
                            local eHRP = v:FindFirstChild("HumanoidRootPart")
                            local eHum = v:FindFirstChild("Humanoid")
                            if eHRP and eHum and eHum.Health > 0 then
                                if (hrp.Position - eHRP.Position).Magnitude < 1000 then
                                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, 5, 0)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    task.wait(0.05)
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades Pirata")

    -- Canjear Códigos
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
                        -- Sailor Piece suele usar un RemoteEvent en RS para códigos
                        local remote = rs:FindFirstChild("Code", true) or rs:FindFirstChild("Redeem", true)
                        if remote then
                            if remote:IsA("RemoteEvent") then remote:FireServer(c)
                            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(c) end
                        end
                    end)
                    task.wait(0.5)
                end
                Fluent:Notify({Title = "Sailor Piece", Content = "Proceso terminado. Algunos códigos requieren nivel alto.", Duration = 4})
            end)
        end
    })

    Tabs.Specific:AddToggle("SP_InfiniteGeppo", {
        Title = "Infinite Sky Jump",
        Default = false,
        Callback = function(Value)
            _G.SP_Geppo = Value
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.SP_Geppo then
                    LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                end
            end)
        end
    })

end

return Module
