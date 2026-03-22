--[[
    🚀 onzeHub - Premium Script Hub
    UI Library: Fluent (dawid-scripts)
    Version: 1.0.0
]]

--!nocheck
---@diagnostic disable: undefined-global

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ LIMPIEZA PREVIA (ANTI-GHOST) ]]
-- Esto borra interfaces viejas si reinicias el script sin cerrar el juego
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "Fluent" or v.Name == "onzeHub" then
        v:Destroy()
    end
end

-- [[ SISTEMA ANTI-DETECCIÓN AVANZADO ]]
local function Protect(instance)
    pcall(function()
        if gethui then
            instance.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(instance)
            instance.Parent = game:GetService("CoreGui")
        else
            instance.Parent = game:GetService("CoreGui")
        end
    end)
end

if getrawmetatable and setreadonly and newcclosure then
    local RawMetatable = getrawmetatable(game)
    local OldIndex = RawMetatable.__index
    local OldNamecall = RawMetatable.__namecall
    
    setreadonly(RawMetatable, false)

    -- Spoofing avanzado: Evita que el juego detecte que tu WalkSpeed es mayor a 16
    RawMetatable.__index = newcclosure(function(Self, Key)
        if not checkcaller() and Self:IsA("Humanoid") then
            if Key == "WalkSpeed" then return 16 end
            if Key == "JumpPower" then return 50 end
        end
        return OldIndex(Self, Key)
    end)

    RawMetatable.__namecall = newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        if not checkcaller() and Method == "Kick" then
            return nil
        end
        return OldNamecall(Self, ...)
    end)

    setreadonly(RawMetatable, true)
else
    warn("onzeHub: Spoofing básico activado.")
end

-- [[ ELIMINADO: Optimizador de Memoria manual ]]
-- (collectgarbage("collect") no funciona en Luau moderno y solo confundía al editor)

local Window = Fluent:CreateWindow({
    Title = "onzeHub",
    SubTitle = "Security System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {}
local HubLoaded = false -- Control de duplicación

local function InitHub()
    local GameID = game.PlaceId
    local MarketplaceService = game:GetService("MarketplaceService")
    local GameInfo = { Name = "Universal" }
    pcall(function()
        GameInfo = MarketplaceService:GetProductInfo(GameID)
    end)

    local GameSupport = {
        [492414410] = "Brookhaven",
        [13772394625] = "Blade Ball",
        [101878803733802] = "Overkill",
        [70390793715007] = "Hooked!",
        [75663528075786] = "How to Train Your Dragon",
        [134933804107672] = "Racket rivals",
        [78912788107663] = "Racket rivals",
        [127794225497302] = "Abyss",
        [9748721976] = "Poppy Playtime",
        [125414435147411] = "Poppy Playtime", -- Servidor/Lobby Chapter 2
        [6872265039] = "Bedwars",
        [117090155680637] = "Rusty Rafts",
        [105555311806207] = "Build a Zoo",
        [4520749081] = "King Legacy",
        [77747658251236] = "Sailor Piece"
    }

    local CurrentGameName = GameSupport[GameID]
    local function CheckName(name, target) return name and string.find(string.lower(name), string.lower(target)) end

    if not CurrentGameName and CheckName(GameInfo.Name, "dragon") then
        CurrentGameName = "How to Train Your Dragon"
        GameID = 75663528075786
    end

    if CurrentGameName == "Racket rivals" then
        GameID = 134933804107672
    end

    -- Redirigir lobby de Poppy Playtime al script principal
    if CurrentGameName == "Poppy Playtime" then
        GameID = 9748721976
    end

    CurrentGameName = CurrentGameName or "Universal"

    -- Crear Pestañas Reales
    Tabs.Main = Window:AddTab({ Title = "Inicio", Icon = "home" })
    Tabs.Universal = Window:AddTab({ Title = "Universal", Icon = "globe" })
    Tabs.Games = Window:AddTab({ Title = "Juegos", Icon = "layout-grid" })
    
    if CurrentGameName ~= "Universal" then
        Tabs.Specific = Window:AddTab({ Title = CurrentGameName, Icon = "zap" })
    end
    
    Tabs.Settings = Window:AddTab({ Title = "Ajustes", Icon = "settings" })

    -- Lógica de inicio
    Tabs.Main:AddParagraph({
        Title = "onzeHub: Premium",
        Content = string.format("Acceso concedido para: %s\nID Usuario: %d\nID Juego: %d\nNombre Juego: %s", 
            game.Players.LocalPlayer.Name, 
            game.Players.LocalPlayer.UserId, 
            game.PlaceId, 
            GameInfo.Name or "Universal"
        )
    })

    -- Bienvenida (Reemplaza al Dialog roto)
    task.spawn(function()
        task.wait(1)
        Fluent:Notify({
            Title = "✅ onzeHub VIP",
            Content = string.format("¡Bienvenido %s! El script para %s se cargó con éxito.", game.Players.LocalPlayer.Name, CurrentGameName),
            Duration = 6
        })
    end)

    -- Función de carga
    local function LoadModule(id, name)
        local idStr = string.format("%.0f", id)
        local url = "https://raw.githubusercontent.com/jaredofff/OnzeStudio/main/src/games/" .. idStr .. ".lua?t=" .. os.time()
        
        local success, mod = pcall(function() 
            return loadstring(game:HttpGet(url))() 
        end)
        
        if success and mod then
            pcall(function() 
                mod.Load(Tabs, Window, Fluent, Options) 
            end)
            Fluent:Notify({Title = "onzeHub", Content = "✓ " .. name .. " cargado correctamente.", Duration = 4})
        else
            warn("onzeHub Error: No se pudo cargar el módulo (" .. tostring(idStr) .. "). Error: " .. tostring(mod))
            Fluent:Notify({Title = "onzeHub Error", Content = "Error al descargar el módulo para " .. name, Duration = 5})
        end
    end

    if Tabs.Specific then 
        task.spawn(function()
            LoadModule(GameID, CurrentGameName) 
        end)
    end

    -- [[ PESTAÑA JUEGOS (MANUAL) ]]
    Tabs.Games:AddSection("Soportados Oficialmente")
    Tabs.Games:AddButton({
        Title = "Cargar: Brookhaven", 
        Callback = function() 
            LoadModule(492414410, "Brookhaven") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Dragon Master", 
        Callback = function() 
            LoadModule(75663528075786, "Dragon Master") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Overkill", 
        Callback = function() 
            LoadModule(101878803733802, "Overkill") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Racket rivals", 
        Callback = function() 
            LoadModule(134933804107672, "Racket rivals") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Abyss", 
        Callback = function() 
            LoadModule(127794225497302, "Abyss") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Poppy Playtime", 
        Callback = function() 
            LoadModule(9748721976, "Poppy Playtime") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Bedwars", 
        Callback = function() 
            LoadModule(6872265039, "Bedwars") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Rusty Rafts", 
        Callback = function() 
            LoadModule(117090155680637, "Rusty Rafts") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Build a Zoo", 
        Callback = function() 
            LoadModule(105555311806207, "Build a Zoo") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: King Legacy", 
        Callback = function() 
            LoadModule(4520749081, "King Legacy") 
        end
    })
    Tabs.Games:AddButton({
        Title = "Cargar: Sailor Piece", 
        Callback = function() 
            LoadModule(77747658251236, "Sailor Piece") 
        end
    })

    -- [[ UNIVERSAL ]]
    Tabs.Universal:AddSlider("WalkSpeed", {
        Title = "Velocidad", 
        Default = 16, 
        Min = 16, 
        Max = 300, 
        Rounding = 1, 
        Callback = function(v) 
            pcall(function() 
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
            end) 
        end
    })
    Tabs.Universal:AddToggle("UniversalESP", {Title = "ESP Jugadores (Básico)", Default = false, Callback = function(v)
        _G.UniversalESP = v
        
        task.spawn(function()
            while _G.UniversalESP do
                -- Luau Moderno (2024-2026): Ya no se usa pairs(), se itera directamente
                for _, player in game.Players:GetPlayers() do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        if not player.Character:FindFirstChild("onze_esp") then
                            local h = Instance.new("Highlight")
                            h.Name = "onze_esp"
                            h.FillColor = Color3.fromRGB(255, 255, 255)
                            -- Práctica moderna de Roblox: Siempre asignar el 'Parent' al final por rendimiento
                            h.Parent = player.Character
                        end
                    end
                end
                task.wait(2)
            end
            
            -- Sistema de limpieza si el usuario lo apaga
            if not _G.UniversalESP then
                for _, player in game.Players:GetPlayers() do
                    if player.Character and player.Character:FindFirstChild("onze_esp") then
                        player.Character:FindFirstChild("onze_esp"):Destroy()
                    end
                end
            end
        end)
    end})

    -- [[ CARGA DE ICONOS, TEMAS Y GUARDADO (OFICIAL) ]]
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        
        -- Ignorar para no mezclar configuraciones visuales con las de hacks
        SaveManager:IgnoreThemeSettings()
        
        -- Separar las configuraciones por juego (muy importante en Fluent)
        InterfaceManager:SetFolder("onzeHub")
        SaveManager:SetFolder("onzeHub/" .. tostring(GameID))
        
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end)

    Window:SelectTab(1) -- Saltar a Inicio

    -- [[ SISTEMA DE CACHÉ DE PERSONAJE ]]
    local LocalPlayer = game.Players.LocalPlayer
    LocalPlayer.CharacterAdded:Connect(function(Character)
        local Hum = Character:WaitForChild("Humanoid", 10)
        if Hum then
            task.wait(1)
            -- Aplicar ajustes guardados al reaparecer
            if Fluent.Options.WalkSpeed then 
                Hum.WalkSpeed = Fluent.Options.WalkSpeed.Value
            end
        end
    end)
    
    -- [[ MARCA DE AGUA CUSTOMIZADA ]]
    task.spawn(function()
        local CoreGui = game:GetService("CoreGui")
        -- Limpiar previous watermark if exists
        local oldWm = CoreGui:FindFirstChild("onzeWatermark")
        if oldWm then oldWm:Destroy() end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "onzeWatermark"
        ScreenGui.Parent = CoreGui
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = ScreenGui
        TextLabel.AnchorPoint = Vector2.new(1, 0)
        TextLabel.Position = UDim2.new(1, -20, 0, 20)
        TextLabel.Size = UDim2.new(0, 0, 0, 25)
        TextLabel.AutomaticSize = Enum.AutomaticSize.X -- Ajusta el tamaño al texto
        TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TextLabel.BorderColor3 = Color3.fromRGB(80, 80, 100)
        TextLabel.BorderSizePixel = 1
        TextLabel.Text = " onzeHub VIP | FPS: -- "
        TextLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
        TextLabel.TextSize = 14
        TextLabel.Font = Enum.Font.Code
        TextLabel.BackgroundTransparency = 0.2
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = TextLabel

        while task.wait(0.5) do
            local start = tick()
            game:GetService("RunService").RenderStepped:Wait()
            local fps = math.floor(1 / (tick() - start))
            
            TextLabel.Text = string.format(" onzeHub VIP | FPS: %d | Ping: %dms ", fps, math.floor(game.Players.LocalPlayer:GetNetworkPing() * 1000) or 0)
        end
    end)
end

-- Inicializar el hub automáticamente sin Key
if not HubLoaded then
    HubLoaded = true
    InitHub()
end

-- Proteger la interfaz
Protect(game:GetService("CoreGui"):FindFirstChild("Fluent") or game:GetService("CoreGui"):FindFirstChild("ScreenGui"))

-- Iconos: https://lucide.dev/icons

SaveManager:LoadAutoloadConfig()
