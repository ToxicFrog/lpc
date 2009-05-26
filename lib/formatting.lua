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

setmetatable (formatting, formatting)


