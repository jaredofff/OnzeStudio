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
    if gethui then
        instance.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(instance)
        instance.Parent = game:GetService("CoreGui")
    else
        instance.Parent = game:GetService("CoreGui")
    end
end

local RawMetatable = getrawmetatable(game)
local OldIndex = RawMetatable.__index
local OldNewIndex = RawMetatable.__newindex
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__index = newcclosure(function(Self, Key)
    if not checkcaller() then
        -- Spoofing de Humanoide
        if (Key == "WalkSpeed" or Key == "JumpPower" or Key == "JumpHeight") and Self:IsA("Humanoid") then
            if Key == "WalkSpeed" then return 16 end
            if Key == "JumpPower" then return 50 end
            if Key == "JumpHeight" then return 7.2 end
        end
        -- Spoofing de Nombre e ID (para evitar logs)
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

local Window = Fluent:CreateWindow({
    Title = "onzeHub",
    SubTitle = "Premium Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Proteger la interfaz
Protect(game:GetService("CoreGui"):FindFirstChild("Fluent") or game:GetService("CoreGui"):FindFirstChild("ScreenGui"))

-- Iconos: https://lucide.dev/icons
local Tabs = {
    Main = Window:AddTab({ Title = "Inicio", Icon = "home" }),
    Universal = Window:AddTab({ Title = "Universal", Icon = "globe" }),
    Games = Window:AddTab({ Title = "Juegos", Icon = "layout-grid" }),
    Settings = Window:AddTab({ Title = "Ajustes", Icon = "settings" })
}

-- [[ DETECCIÓN DE JUEGOS ]]
local GameID = game.PlaceId
local GameSupport = {
    [492414410] = "Brookhaven",
    [13772394625] = "Blade Ball",
    [2753915549] = "Blox Fruits"
}

local CurrentGameName = GameSupport[GameID] or "Universal"

if CurrentGameName ~= "Universal" then
    Tabs.Specific = Window:AddTab({ Title = CurrentGameName, Icon = "zap" })
    Fluent:Notify({
        Title = "onzeHub",
        Content = "Juego detectado: " .. CurrentGameName,
        Duration = 5
    })
end

local Options = Fluent.Options

-- [[ PESTAÑA INICIO ]] 
Tabs.Main:AddParagraph({
    Title = "¡Bienvenido a onzeHub!",
    Content = "Usuario: " .. game.Players.LocalPlayer.Name .. "\nID: " .. game.Players.LocalPlayer.UserId
})

Tabs.Main:AddButton({
    Title = "Copiar Discord",
    Description = "Únete a nuestra comunidad",
    Callback = function()
        setclipboard("https://discord.gg/V6FTB4u8ZH")
        Fluent:Notify({
            Title = "Copiado",
            Content = "Enlace de Discord copiado al portapapeles",
            Duration = 5
        })
    end
})

-- [[ PESTAÑA DE JUEGO ESPECÍFICO ]]
if Tabs.Specific then
    local Success, GameModule = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/jaredofff/OnzeStudio/main/src/games/" .. GameID .. ".lua"))()
    end)

    if Success and GameModule and GameModule.Load then
        GameModule.Load(Tabs, Window, Fluent, Options)
    else
        Tabs.Specific:AddParagraph({
            Title = "Aviso",
            Content = "No se pudieron cargar las funciones específicas para este juego o el módulo aún no existe."
        })
        warn("onzeHub: No se pudo cargar el módulo para el ID " .. GameID)
    end
end

-- [[ PESTAÑA JUEGOS (LISTA GENERAL) ]]
Tabs.Games:AddSection("Juegos Soportados")
for id, name in pairs(GameSupport) do
    Tabs.Games:AddParagraph({
        Title = name,
        Content = "ID: " .. id
    })
end
Tabs.Universal:AddSection("Movimiento")

Tabs.Universal:AddSlider("WalkSpeed", {
    Title = "Velocidad al caminar",
    Description = "Ajusta tu velocidad (Default: 16)",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

Tabs.Universal:AddSlider("JumpHeight", {
    Title = "Altura de Salto",
    Description = "Ajusta la potencia de salto",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
    end
})

Tabs.Universal:AddToggle("InfiniteJump", {
    Title = "Salto Infinito",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJump = Value
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if _G.InfiniteJump then
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
})

-- [[ ACTUALIZACIÓN AUTOMÁTICA DE PERSONAJE ]]
game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(1)
    if Options.WalkSpeed then 
        Character:WaitForChild("Humanoid").WalkSpeed = Options.WalkSpeed.Value
    end
    if Options.JumpHeight then
        local Hum = Character:WaitForChild("Humanoid")
        Hum.JumpPower = Options.JumpHeight.Value
        Hum.UseJumpPower = true
    end
end)

-- [[ PESTAÑA AJUSTES (PERSONALIZACIÓN) ]]
Tabs.Settings:AddSection("Apariencia")

Tabs.Settings:AddDropdown("ThemeDropdown", {
    Title = "Tema Visual",
    Values = {"Dark", "Light", "Rose", "Aqua", "Amethyst"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        Fluent:SetTheme(Value)
    end
})

Tabs.Settings:AddToggle("AcrylicToggle", {
    Title = "Efecto Acrílico (Transparencia)",
    Default = true,
    Callback = function(Value)
        Window:SetAcrylic(Value)
    end
})

Tabs.Settings:AddSection("Sistema")

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "onzeHub Cargado",
    Content = "Ejecución exitosa",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
