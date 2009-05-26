output = {}

local function parse(format)
    local options = {}
    format = "format="..format
    
    for k,v in format:gmatch('([^,]+)=([^,]*)') do
        options[k] = v
    end
    
    return options
end

function output.gen(chapter, format)
    lp.chapter = chapter

    -- "type" is passed to us right from argv, it's our responsibility to parse it
    local options = parse(format)
    
    local f = require("lib.output."..options.format)
    f(chapter, options)
end

function output.makefn(f, filename)
    return function(chapter, options)
        local defaults = {
            o = "%s/%s" % chapter.dir % filename;
        }
        setmetatable(options, { __index = defaults })
        
        fout = assert(io.open(options.o, "w"))
        fout:write(f(chapter, options))
        fout:close()
    end
end

function output.expand(str, replacer)
    local str,n = str:gsub("%.(%w+)(%b{})", function(tag,buf) return replacer(tag, buf:sub(2,-2)) end)
    if n > 0 then
        return output.expand(str, replacer)
    end
    return str
end

