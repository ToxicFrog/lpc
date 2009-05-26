-- permit 'foo % bar % baz' as a synonym for 'foo:format(bar, baz)
local function str__mod(lhs, rhs)
    if type(rhs) == "table" then
        return lhs:format(unpack(rhs))
    else
        return lhs:gsub('%%', '%%%%'):gsub('%%%%', '%%', 1):format(rhs)
    end
end
getmetatable("").__mod = str__mod


-- printf to stderr
function eprintf(fmt, ...)
    io.stderr:write(fmt:format(...))
end


-- display a warning
function warn(...)
    eprintf(...)
end


-- display an error message and exit
function die(...)
    warn(...)
    os.exit(1)
end


-- "safe require", do a require without raising an error
function srequire(...)
    local result,module = pcall(require, ...)
    if result then
        return module
    else
        return nil,module
    end
end

