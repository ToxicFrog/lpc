-- load point for the formatting library, ie, the part that turns formatting
-- directives like ss() into the intermediate representation

-- global output function used by all formatting directives
-- like printf, but appends to the current chapter's text buffer
function emit(...)
    lp.chapter.text[#lp.chapter.text+1] = string.format(...)
end

-- load all configured formatting libraries
formatting = {}
for _,name in ipairs(lp.formatting) do
    require ("lib.formatting.%s" % name)
end

function formatting.lfsensitive(yesno)
    local lastline = math.huge
    local sourcefile = "@"..lp.chapter.dir.."post.lua"
    local activelines
    
    if yesno then
        local function wshook(what, where)
            local info = debug.getinfo(3)
            if info.source ~= sourcefile then return end

            local where = info.currentline
            activelines = activelines or debug.getinfo(3,"L").activelines
            
            if where > lastline then
                repeat
                    lp.chapter.text[#lp.chapter.text+1] = ("\n")
                    lastline = lastline + 1
                until activelines[lastline]
            end
            lastline = where
        end
        debug.sethook(wshook, "c")
    else
        debug.sethook()
    end
end

setmetatable (formatting, formatting)


