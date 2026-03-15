--[[
    onzeHub - Blade Ball Module
    ID: 13772394625
]]

local Module = {}

function Module.Load(Tabs, Window, Fluent, Options)
    Tabs.Specific:AddSection("Funciones de Blade Ball")
    Tabs.Specific:AddToggle("AutoParry", {Title = "Auto Parry", Default = false})
    
    Tabs.Specific:AddButton({
        Title = "Info",
        Callback = function()
            Fluent:Notify({Title = "onzeHub", Content = "Módulo de Blade Ball cargado", Duration = 3})
        end
    })
end

return Module
