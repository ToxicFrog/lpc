local cache = {}

if _G[".saverestore"] then
    cache = _G[".saverestore"]
else
    _G[".saverestore"] = cache
end

function POST(text)
    if push then
        table.insert(cache, text)
        return text
        
    elseif pop then
        return table.remove(cache)
        
    elseif save then
        cache[key] = text
        return text
        
    elseif restore then
        return cache[key]
        
    end
    error("No operation passed to package saverestore") 
end