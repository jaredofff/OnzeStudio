--[[
    onzeHub - Steal Eggs from Goose!
    ID: 79244238995921
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información del Ganso")

    Tabs.Specific:AddParagraph({
        Title = "Steal Eggs v1",
        Content = "Script básico para recolectar huevos y evitar al ganso."
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
    -- [[ SECCIÓN: AUTOMATIZACIÓN ]]
    -- =============================================
    Tabs.Specific:AddSection("Auto Farm")

    Tabs.Specific:AddToggle("Goose_AutoCollect", {
        Title = "Auto Recolectar Huevos",
        Description = "Camina automáticamente hacia los huevos cercanos.",
        Default = false,
        Callback = function(Value)
            _G.Goose_AutoCollect = Value
        end
    })

    task.spawn(function()
        while true do
            if _G.Goose_AutoCollect then
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    
                    -- Buscar huevos en el mapa
                    local eggs = workspace:FindFirstChild("Eggs") or workspace
                    local target = nil
                    local minDist = 500
                    
                    for _, v in pairs(eggs:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name == "Egg" or v.Name == "GoldenEgg") then
                            local dist = (hrp.Position - v.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                target = v
                            end
                        end
                    end
                    
                    if target and _G.Goose_AutoCollect then
                        hrp.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                        task.wait(0.2)
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- =============================================
    -- [[ SECCIÓN: MOVIMIENTO ]]
    -- =============================================
    Tabs.Specific:AddSection("Movimiento VIP")

    Tabs.Specific:AddToggle("Goose_InfJump", {
        Title = "Salto Infinito",
        Default = false,
        Callback = function(v) _G.Goose_InfJump = v end
    })

    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.Goose_InfJump then
            local hum = getChar() and getChar():FindFirstChild("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end)

    Tabs.Specific:AddToggle("Goose_Noclip", {
        Title = "Noclip",
        Default = false,
        Callback = function(v) _G.Goose_Noclip = v end
    })

    RunService.Stepped:Connect(function()
        if _G.Goose_Noclip and getChar() then
            for _, v in pairs(getChar():GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

end

return Module
