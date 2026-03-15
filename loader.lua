--[[
    onzeHub - Loader
    Instrucciones: Sube el contenido de src/init.lua a GitHub y reemplaza la URL abajo.
]]

local function LoadScript()
    -- En el futuro, aquí pondrás tu URL de GitHub Raw
    -- Ejemplo: loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()
    
    warn("onzeHub: Cargando componentes...")
    
    -- Versión en la nube de onzeHub
    loadstring(game:HttpGet("https://raw.githubusercontent.com/jaredofff/OnzeStudio/main/src/init.lua"))()
    print("onzeHub: Sistema cargado desde GitHub correctamente.")
end

local success, err = pcall(LoadScript)

if not success then
    warn("Error al cargar onzeHub: " .. tostring(err))
end
