--[[
    onzeHub - Loader
    Instrucciones: Sube el contenido de src/init.lua a GitHub y reemplaza la URL abajo.
]]

local function LoadScript()
    -- En el futuro, aquí pondrás tu URL de GitHub Raw
    -- Ejemplo: loadstring(game:HttpGet("https://raw.githubusercontent.com/..."))()
    
    warn("onzeHub: Cargando componentes...")
    
    -- Por ahora, cargamos el código base directamente para que veas cómo funciona
    -- NOTA: En un exploit real, podrías usar readfile() para probar localmente
    loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    print("Sistema listo. Edita src/init.lua para personalizar tu Hub.")
end

local success, err = pcall(LoadScript)

if not success then
    warn("Error al cargar onzeHub: " .. tostring(err))
end
