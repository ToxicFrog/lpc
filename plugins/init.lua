-- This plugin is automatically run for every file loaded.
-- It defines the basic commands necessary to do anything useful:
--  \use
--  \def
--  \\
-- As well as the following useful macros, which use "out" and "saverestore"
--  \out
--  \save
--  \restore


local packages = {}

function PRE(text)
    LOG("Processing file %s", FILE)
end

function use(package, ...)
    local options = {}
    for _,opt in ipairs {...} do
        local k,v = opt:match("([^=]+)=(.*)")
        if k then
            options[k] = v
        else
            options[opt] = true
        end
    end

    table.insert(packages, { package, options })
    return ""
end

function rem(text)
    return ""
end
ALIAS("\\", rem)

function include(file)
    local dir = FILE:gsub('[^/]+$', '')
    return assert(io.open('./'..dir..'/'..file, "r")):read("*a")
end

function def(name, body)
    local function f(...)
        local argv = {...}
        return (body:gsub("\\(%d+)", function(i) return argv[tostring(i)] end))
    end
    ALIAS(name, f)

    return ""
end

function save(name)
    if #name > 0 then
        return [[\use{saverestore}{save}{name=%s}]] % name
    else
        return [[\use{saverestore}{push}]]
    end
end

function restore(name)
    if #name > 0 then
        return [[\use{saverestore}{restore}{name=%s}]] % name
    else
        return [[\use{saverestore}{pop}]]
    end
end

function out(name)
    if name:match("^%.") then
        return [[\use{out}{file=%s%s}]] % { FILE:gsub("%.[^.]+", ""), name }
    elseif #name > 0 then
        return [[\use{out}{file=%s}]] % name
    else
        return [[\use{out}]]
    end
end

function POST(text)
    for _,package in ipairs(packages) do
        text = lp.filter(text, unpack(package))
    end
    return text
end
