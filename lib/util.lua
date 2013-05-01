function string:split(pattern)
    local split = {}
    local start = 1
    
    for first,last in self:gmatch("()"..pattern.."()") do
        table.insert(split, self:sub(start, first-1))
        start = last
    end
    table.insert(split, self:sub(start, -1))
    
    return split
end

function string:trim()
    return (self:gsub("^%s+", ""):gsub("%s+$", ""))
end

getmetatable("").__mod = function(self, args)
    if type(args) ~= "table" then
        args = { args }
    end
    return string.format(self, unpack(args))
end

-- returns the contents of the given file
function io.fdata(filename)
    local fd,err = io.open(filename, "rb")
    if not fd then return nil,err end
    
    local buf = fd:read "*a"; fd:close()
    return buf
end

-- returns the size of the given file or nil,error
function io.fsize(filename)
    local fd,err = io.open(filename, "rb")
    if not fd then return nil,err end
    
    local size = fd:seek("end"); fd:close()
    return size
end

function io.printf(...)
    return io.write(string.format(...))
end

function io.eprintf(...)
    return io.stderr:write(string.format(...))
end
