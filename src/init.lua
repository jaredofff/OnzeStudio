--[[
    🚀 onzeHub - Premium Script Hub
    UI Library: Fluent (dawid-scripts)
    Version: 1.0.0
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "onzeHub | " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    SubTitle = "by Antigravity & User",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

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
    if GameID == 492414410 then -- Brookhaven
        Tabs.Specific:AddSection("Funciones de Brookhaven")
        Tabs.Specific:AddButton({
            Title = "Desbloquear Todos los Autos",
            Callback = function()
                print("Lógica para Brookhaven...")
            end
        })
    elseif GameID == 13772394625 then -- Blade Ball
        Tabs.Specific:AddSection("Funciones de Blade Ball")
        Tabs.Specific:AddToggle("AutoParry", {Title = "Auto Parry", Default = false})
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

-- [[ PESTAÑA AJUSTES ]]
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
