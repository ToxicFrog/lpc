local function fexists(path)
    local fd = io.open(path, "r")
    if not fd then
        return false
    end
    fd:close()
    return true
end

return function(path)
    if not fexists(path) then
        print("[missing] %s" % path)
    end
    
    return path
end
