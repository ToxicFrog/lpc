local cache = {}

local function loadcache(name, obj)
    for line in io.lines(".cache-"..name) do
        local k,v = line:match("([^\t])+\t(.*)")
        obj[k] = v
    end
end

function cache.open(name)
    local obj = {}
    
    -- read cache contents
    pcall(loadcache, name, obj)
    
    return setmetatable(obj, { __index = cache, name = name })
end

function cache:get(path)
    return self[self:key(path)]
end

function cache:put(path, url)
    self[self:key(path)] = url
end

function cache:key(path)
    local fd = io.open(path, "r")
    if not fd then
        return 0 -- dummy key - missing files are never reported to exist in the cache
    end
    
    local size = fd:seek("end")
    fd:close()
    
    return [[%d%s]] % { size, path }
end

function cache:save()
    -- write cache contents
    local fd = assert(io.open(".cache-"..getmetatable(self).name, "w"))
    
    for k,v in pairs(self) do
        fd:write([[%s\t%s\n]] % { k, v })
    end
    
    fd:close()
end

return cache