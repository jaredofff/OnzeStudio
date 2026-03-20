--[[
    onzeHub - Build a Zoo
    ID: 105555311806207
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Información")

    Tabs.Specific:AddParagraph({
        Title = "Build a Zoo",
        Content = "Script de onzeHub cargado para Build a Zoo. ¡Gestiona tu zoo y consigue las mejores mascotas!"
    })

    -- Helpers
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function getChar() return LocalPlayer.Character end
    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    -- =============================================
    -- [[ SECCIÓN: AUTOFARM ]]
    -- =============================================
    Tabs.Specific:AddSection("Autofarm / Automatización")

    Tabs.Specific:AddToggle("BZ_AutoCollect", {
        Title = "Auto Recoger Monedas/Items",
        Description = "Recoge automáticamente las monedas y drops cercanos.",
        Default = false,
        Callback = function(Value)
            _G.BZ_AutoCollect = Value
            task.spawn(function()
                while _G.BZ_AutoCollect do
                    pcall(function()
                        local hrp = getHRP()
                        if not hrp then return end
                        
                        -- Buscar monedas o items en el workspace
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Name == "Coin" or v.Name == "Item" or v.Name == "Currency") then
                                if (hrp.Position - v.Position).Magnitude < 50 then
                                    v.CFrame = hrp.CFrame
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    })

    -- =============================================
    -- [[ SECCIÓN: VISUALES ]]
    -- =============================================
    Tabs.Specific:AddSection("Visuales")

    Tabs.Specific:AddToggle("BZ_FullBright", {
        Title = "FullBright (Iluminación)",
        Description = "Elimina las sombras y hace que todo sea brillante.",
        Default = false,
        Callback = function(Value)
            if Value then
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            else
                game:GetService("Lighting").Brightness = 1
                game:GetService("Lighting").GlobalShadows = true
                game:GetService("Lighting").Ambient = Color3.fromRGB(127, 127, 127)
            end
        end
    })

    -- =============================================
    -- [[ SECCIÓN: UTILIDADES ]]
    -- =============================================
    Tabs.Specific:AddSection("Utilidades")

    Tabs.Specific:AddButton({
        Title = "Infinito Salto",
        Description = "Te permite saltar en el aire múltiples veces.",
        Callback = function()
            local uis = game:GetService("UserInputService")
            uis.JumpRequest:Connect(function()
                local hum = getChar() and getChar():FindFirstChild("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            Fluent:Notify({Title = "Build a Zoo", Content = "Salto infinito activado.", Duration = 3})
        end
    })

    -- Canjear Códigos
    Tabs.Specific:AddButton({
        Title = "Canjear Códigos Activos (Marzo 2026)",
        Description = "Canjea automáticamente +30 códigos (Gems, Tickets, Pet Eggs).",
        Callback = function()
            local codes = {
                "OCEANHEART0", "ROMANCEBLOOMS", "WEEKENDJOY5", "SANTASWORKS",
                "SANTAGIFT25", "HOLIDAYFUN1", "TUESDAYFUN1", "CHRISTMAS12",
                "FIXTHEBUGS1", "ADMINABUSE1", "ACORN251204", "XMASADVENT5",
                "FRIDAYGIFT5", "ZooFarmers", "BLACKFRIDAY", "WAEX662ERC3",
                "9WC77XXCM5A", "LandCompensation", "BHNR9CB9TNC", "A38JBJ3TSSE",
                "9HDARHCQMWS", "N5HZKRRT2DF", "ZTWPH3WW8SJ", "ADQZP3MBW6N",
                "3XKK8Z2WB6G", "N7A68Q82H83", "4XW5RG4CHRY", "DelayGift",
                "60KCCU919", "50KCCU0912", "ZooFish829", "FIXERROR819",
                "BugFixes", "U2CA518SC5", "X2CA821BA3", "55PA21N8y2"
            }
            
            Fluent:Notify({Title = "Build a Zoo", Content = "Canjeando " .. #codes .. " códigos...", Duration = 5})
            
            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                -- Buscar el remote de códigos
                local remote = rs:FindFirstChild("RedeemCode", true) 
                    or rs:FindFirstChild("CodeRedeem", true)
                    or rs:FindFirstChild("Codes", true)
                    or rs:FindFirstChild("Redeem", true)

                if remote then
                    for _, code in ipairs(codes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(code)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(code)
                            end
                        end)
                        task.wait(0.3)
                    end
                    Fluent:Notify({Title = "Build a Zoo", Content = "Códigos procesados.", Duration = 4})
                else
                    Fluent:Notify({Title = "Build a Zoo", Content = "No se encontró el Remote de códigos. Intenta abrir la tienda antes.", Duration = 5})
                end
            end)
        end
    })
end

return Module
