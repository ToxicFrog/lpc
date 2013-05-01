package.path = package.path..";lib/?.lua;lib/luasocket/?.lua"
package.cpath = package.cpath..";lib/?.so;lib/?.dll;lib/luasocket/?.so;lib/luasocket/?.dll"

require "util"

lp = {}

-- for general "markers", we use 0xFE, a module-specific string, and then 0xFF
-- 0xFE and 0xFF are both outside ASCII and illegal in UTF-8, and thus should
-- (hopefully) never appear in input data
-- if you're using UTF-16, fuck off
lp.SEP = string.char(0xFE)..","..string.char(0xFF)

function lp.expand(text, macros)
    local expand_one,expand_all
    
    function expand_all(text)
        return (text:gsub("}{", lp.SEP):gsub([[\([^{%s]+)(%b{})]], expand_one):gsub(lp.SEP, "}{"))
    end
    
    function expand_one(name, args)
        if not macros[name] then return end
        
        args = args:sub(2,-2):split(lp.SEP)
        
        return expand_all(macros[name](unpack(args)))
    end
    
    
    if macros.PRE then
        text = macros.PRE(text) or text
    end
    
    text = expand_all(text)
    
    if macros.POST then
        text = macros.POST(text) or text
    end

    return text
end

function lp.filter(text, filter, options)
    local function mkenv()
        local env = {}
        for k,v in pairs(options or {}) do env[k] = v end
        
        env.FILE = lp.FILE
        env.MARK = string.char(0xFE)..filter..string.char(0xFF)
        env._ENV = env
        
        function env.ALIAS(new, old)
            env[new] = old
        end
        
        function env.LOG(...)
            return io.eprintf("[%s] %s\n", filter, string.format(...))
        end
        
        return setmetatable(env, {__index = _G})
    end
    
    local macros = mkenv()
    local loader = assert(loadfile("plugins/"..filter..".lua"))
    setfenv(loader, macros)
    loader()
    
    return lp.expand(text, macros)
end

for _,file in ipairs { ... } do
    lp.FILE = file
    lp.filter(assert(io.fdata(file)), "init")
end
