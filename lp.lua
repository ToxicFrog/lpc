#!/usr/bin/env luajit

package.path = package.path..";lib/?.lua;lib/luasocket/?.lua"
package.cpath = package.cpath..";lib/?.so;lib/?.dll;lib/luasocket/?.so;lib/luasocket/?.dll"

require "util"

lp = {}

-- for general "markers", we use 0xFE, a module-specific string, and then 0xFF
-- 0xFE and 0xFF are both outside ASCII and illegal in UTF-8, and thus should
-- (hopefully) never appear in input data
-- if you're using UTF-16, fuck off
lp.SEP = string.char(0xFE)..","..string.char(0xFF)

-- Given document text and a [name => function] mapping of macros, expand all
-- of the macros in the text. Generally this is run for one module at a time,
-- so it'll be called multiple times for any given text.
function lp.expand(text, macros)
    local expand_one,expand_all

    -- Replace all }{ with the special SEP sequence. Then find all macros, of
    -- form \foo{...}, and call expand_one to expand their contents. Then turn
    -- all SEPs back into }{.
    function expand_all(text)
        return (text:gsub("}{", lp.SEP):gsub([[\([^{%s]+)(%b{})]], expand_one):gsub(lp.SEP, "}{"))
    end

    -- We're passed a name and an argument list. The arguments are delimited
    -- with SEP and surrounded with {} due to limitations in expand_all. Breaks
    -- the list into individual arguments, calls the named macro with them, and
    -- returns the result.
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

-- Given the name of a filter module, load it and then feed the results to
-- lp.expand.
-- This sets up an environment for the filter with some special globals set up,
-- then loads the filter module into it and calls expand.
function lp.filter(text, filter, options)
    local function mkenv()
        local env = {}
        for k,v in pairs(options or {}) do env[k] = v end

        --
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

-- We load each file with the "init" filter and nothing else. This defines some
-- basic macros, including \include and \use, which the file will use (if
-- needed) to load additional filters. \use adds the filters to a list which is
-- run by POST once init has finished all other processing.
for _,file in ipairs { ... } do
    lp.FILE = file
    lp.filter(assert(io.fdata(file)), "init")
end
