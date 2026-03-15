--[[
    🚀 onzeHub - Premium Script Hub
    UI Library: Fluent (dawid-scripts)
    Version: 1.0.0
]]

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

-- [[ OPTIMIZADOR DE MEMORIA (GC) ]]
task.spawn(function()
    while task.wait(60) do
        local _ = collectgarbage("count")
        collectgarbage("collect")
    end
end)

local Window = Fluent:CreateWindow({
    Title = "onzeHub",
    SubTitle = "Security System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- [[ SISTEMA DE LLAVES (LOGIN) ]]
local LoginTab = Window:AddTab({ Title = "🔑 Acceso", Icon = "key" })
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
        [75663528075786] = "How to Train Your Dragon"
    }

    local CurrentGameName = GameSupport[GameID]
    local function CheckName(name, target) return name and string.find(string.lower(name), string.lower(target)) end

    if not CurrentGameName and CheckName(GameInfo.Name, "dragon") then
        CurrentGameName = "How to Train Your Dragon"
        GameID = 75663528075786
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

    -- Función de carga
    local function LoadModule(id, name)
        local url = "https://raw.githubusercontent.com/jaredofff/OnzeStudio/main/src/games/" .. id .. ".lua?t=" .. os.time()
        local success, mod = pcall(function() 
            return loadstring(game:HttpGet(url))() 
        end)
        
        if success and mod then
            pcall(function() 
                mod.Load(Tabs, Window, Fluent, Fluent.Options) 
            end)
            Fluent:Notify({Title = "onzeHub", Content = name .. " cargado.", Duration = 3})
        end
    end

    if Tabs.Specific then LoadModule(GameID, CurrentGameName) end

    -- [[ PESTAÑA JUEGOS (MANUAL) ]]
    Tabs.Games:AddSection("Soportados Oficialmente")
    Tabs.Games:AddButton({Title = "Cargar: Brookhaven", Callback = function() LoadModule(492414410, "Brookhaven") end})
    Tabs.Games:AddButton({Title = "Cargar: Dragon Master", Callback = function() LoadModule(75663528075786, "Dragon Master") end})
    Tabs.Games:AddButton({Title = "Cargar: Overkill", Callback = function() LoadModule(101878803733802, "Overkill") end})

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
        while _G.UniversalESP do
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("onze_esp") then
                        local h = Instance.new("Highlight", player.Character)
                        h.Name = "onze_esp"
                        h.FillColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
            task.wait(2)
        end
    end})

    -- [[ CARGA DE ICONOS Y TEMAS OPTIMIZADA ]]
    pcall(function()
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:SetLibrary(Fluent)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end)

    Window:SelectTab(2) -- Saltar a Inicio

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
end

-- Pestaña Login (Única activa al inicio)
LoginTab:AddSection("Seguridad")
local MyKey = ""
LoginTab:AddInput("Key", {Title = "Key", Callback = function(v) MyKey = v end})

LoginTab:AddButton({
    Title = "Entrar",
    Callback = function()
        if MyKey == "ONZE-2026" then
            if HubLoaded then return end
            HubLoaded = true
            InitHub()
            
            -- ELIMINAR ACCESO (Solución definitiva al duplicado y corrupción)
            task.spawn(function()
                pcall(function()
                    LoginTab:Destroy() -- Destruye el objeto de la lista de tabs
                end)
                Window:SelectTab(2) -- Asegurar cambio a Inicio
            end)
        else
            Fluent:Notify({Title = "Error", Content = "Key inválida", Duration = 3})
        end
    end
})

-- Proteger la interfaz
Protect(game:GetService("CoreGui"):FindFirstChild("Fluent") or game:GetService("CoreGui"):FindFirstChild("ScreenGui"))

-- Iconos: https://lucide.dev/icons
-- The actual Tabs creation is now inside InitHub()

-- All core logic is now moved inside InitHub() for security.
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
