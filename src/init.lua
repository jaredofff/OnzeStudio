--[[
    🚀 onzeHub - Premium Script Hub
    UI Library: Fluent (dawid-scripts)
    Version: 1.0.0
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

-- Compatibilidad: Solo activar spoofing si el ejecutor lo soporta
if getrawmetatable and setreadonly and newcclosure then
    local RawMetatable = getrawmetatable(game)
    local OldIndex = RawMetatable.__index
    local OldNamecall = RawMetatable.__namecall
    
    setreadonly(RawMetatable, false)

    RawMetatable.__index = newcclosure(function(Self, Key)
        if not checkcaller() then
            if (Key == "WalkSpeed" or Key == "JumpPower" or Key == "JumpHeight") and Self:IsA("Humanoid") then
                if Key == "WalkSpeed" then return 16 end
                if Key == "JumpPower" then return 50 end
                if Key == "JumpHeight" then return 7.2 end
            end
            if Key == "Name" and (Self == game.Players.LocalPlayer or Self == game.Players.LocalPlayer.Character) then
                return "Player"
            end
        end
        return OldIndex(Self, Key)
    end)

    RawMetatable.__namecall = newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if not checkcaller() and Method == "Kick" then
            warn("onzeHub: Intento de KICK bloqueado!")
            return nil
        end
        return OldNamecall(Self, unpack(Args))
    end)

    setreadonly(RawMetatable, true)
else
    warn("onzeHub: Tu ejecutor no soporta protección de Metatablas. Cargando modo básico...")
end

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

local function InitHub()
    -- [[ DETECCIÓN DE JUEGOS ]]
    local GameID = game.PlaceId
    local MarketplaceService = game:GetService("MarketplaceService")
    local GameInfo = {}

    pcall(function()
        GameInfo = MarketplaceService:GetProductInfo(GameID)
    end)

    local GameSupport = {
        [492414410] = "Brookhaven",
        [13772394625] = "Blade Ball",
        [2753915549] = "Blox Fruits",
        [129907317028750] = "Be Dino",
        [101878803733802] = "Overkill",
        [70390793715007] = "Hooked!",
        [75663528075786] = "How to Train Your Dragon"
    }

    -- Detección por ID o por nombre del producto
    local CurrentGameName = GameSupport[GameID]
    local function CheckName(name, target)
        return name and string.find(string.lower(name), string.lower(target))
    end

    if not CurrentGameName and CheckName(GameInfo.Name, "Brookhaven") then
        CurrentGameName = "Brookhaven"
        GameID = 492414410
    elseif not CurrentGameName and CheckName(GameInfo.Name, "Blade Ball") then
        CurrentGameName = "Blade Ball"
        GameID = 13772394625
    elseif not CurrentGameName and CheckName(GameInfo.Name, "Overkill") then
        CurrentGameName = "Overkill"
        GameID = 101878803733802
    elseif not CurrentGameName and CheckName(GameInfo.Name, "Hooked") then
        CurrentGameName = "Hooked!"
        GameID = 70390793715007
    elseif not CurrentGameName and CheckName(GameInfo.Name, "dragon") then
        CurrentGameName = "How to Train Your Dragon"
        GameID = 75663528075786
    end

    CurrentGameName = CurrentGameName or "Universal"

    -- Cargar Pestañas Reales
    Tabs.Main = Window:AddTab({ Title = "Inicio", Icon = "home" })
    Tabs.Universal = Window:AddTab({ Title = "Universal", Icon = "globe" })
    Tabs.Games = Window:AddTab({ Title = "Juegos", Icon = "layout-grid" })
    
    if CurrentGameName ~= "Universal" then
        Tabs.Specific = Window:AddTab({ Title = CurrentGameName, Icon = "zap" })
    end
    
    Tabs.Settings = Window:AddTab({ Title = "Ajustes", Icon = "settings" })

    local Options = Fluent.Options

    -- [[ PESTAÑA INICIO ]] 
    Tabs.Main:AddParagraph({
        Title = "¡Bienvenido a onzeHub!",
        Content = string.format("Usuario: %s\nID Usuario: %d\nID Juego: %d\nNombre: %s", 
            game.Players.LocalPlayer.Name, 
            game.Players.LocalPlayer.UserId, 
            game.PlaceId, 
            GameInfo.Name or "No detectado"
        )
    })
    Fluent:Notify({
        Title = "onzeHub",
        Content = "Bienvenido de nuevo, " .. game.Players.LocalPlayer.Name,
        Duration = 5
    })

    -- [[ CARGA DE MÓDULOS ESPECÍFICOS ]]
    local function LoadModule(TargetID, Name)
        local ModuleURL = "https://raw.githubusercontent.com/jaredofff/OnzeStudio/main/src/games/" .. TargetID .. ".lua?t=" .. os.time()
        local Success, GameModuleFunc = pcall(function()
            return loadstring(game:HttpGet(ModuleURL))()
        end)

        if Success and GameModuleFunc and type(GameModuleFunc.Load) == "function" then
            pcall(function()
                GameModuleFunc.Load(Tabs, Window, Fluent, Options)
            end)
            Fluent:Notify({Title = "onzeHub", Content = "Módulo [" .. Name .. "] cargado.", Duration = 3})
        end
    end

    if Tabs.Specific then
        LoadModule(GameID, CurrentGameName)
    end

    -- Botones de carga manual
    Tabs.Main:AddSection("Atajos de Juegos")
    Tabs.Main:AddButton({
        Title = "Forzar: Brookhaven",
        Callback = function() LoadModule(492414410, "Brookhaven") end
    })
    Tabs.Main:AddButton({
        Title = "Forzar: Overkill",
        Callback = function() LoadModule(101878803733802, "Overkill") end
    })
    Tabs.Main:AddButton({
        Title = "Forzar: Dragon",
        Callback = function() LoadModule(75663528075786, "How to Train Your Dragon") end
    })

    -- Universal
    Tabs.Universal:AddSlider("WalkSpeed", {
        Title = "Velocidad", 
        Default = 16, 
        Min = 16, 
        Max = 250, 
        Rounding = 1, 
        Callback = function(V) 
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = V 
        end
    })
    
    -- Ajustes y Finalización
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:SetLibrary(Fluent)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    Window:SelectTab(2) -- Ir a Inicio automáticamente
end

LoginTab:AddSection("Verificación de Licencia")

local MyKey = ""
LoginTab:AddInput("KeyInput", {
    Title = "Introduce tu Key",
    Description = "Consigue una Key en nuestro Discord",
    Default = "",
    Placeholder = "Escribe la Key aquí...",
    Callback = function(Value)
        MyKey = Value
    end
})

LoginTab:AddButton({
    Title = "Verificar Key",
    Description = "Valida tu suscripción",
    Callback = function()
        -- NOTA: Esto es una validación local. Para venta real, se conecta a una API.
        if MyKey == "ONZE-2026" then
            Fluent:Notify({
                Title = "Acceso Concedido",
                Content = "Cargando módulos de onzeHub...",
                Duration = 3
            })
            InitHub()
            -- Opcional: Podríamos cerrar la pestaña de login si la UI lo soporta
        else
            Fluent:Notify({
                Title = "Error de Acceso",
                Content = "La Key introducida es incorrecta o ha expirado.",
                Duration = 4
            })
        end
    end
})

LoginTab:AddButton({
    Title = "Obtener Key gratis",
    Callback = function()
        setclipboard("https://discord.gg/onzehub") -- Link de ejemplo
        Fluent:Notify({
            Title = "Enlace Copiado",
            Content = "Se ha copiado el link del Discord al portapapeles.",
            Duration = 3
        })
    end
})

-- Proteger la interfaz
Protect(game:GetService("CoreGui"):FindFirstChild("Fluent") or game:GetService("CoreGui"):FindFirstChild("ScreenGui"))

-- Iconos: https://lucide.dev/icons
-- The actual Tabs creation is now inside InitHub()

-- All core logic is now moved inside InitHub() for security.
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
