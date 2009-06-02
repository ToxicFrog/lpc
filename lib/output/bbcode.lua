local styles = {}

local function basic_style(tag)
    local format = "["..tag.."]%s[/"..tag.."]"
    styles[tag] = function(buf)
        return format % buf
    end
end

-- basic bbcode tags
for _,tag in ipairs { "b", "s", "u", "super", "sub", "pre", "tt", "code", "spoiler" } do
    basic_style(tag)
end

-- special handling for italics - if they're on, turns them off, and if off, on
function styles.i(buf)
    return "[i]%s[/i]" % buf:gsub("%.i(%b{})", ".ii%1")
end

function styles.ii(buf)
    return "[/i]%s[i]" % buf:gsub("%.ii(%b{})", ".i%1")
end

function styles.img(buf)
    return '[img]%s[/img]' % buf
end

function styles.url(buf)
    local href,text = buf:match("(%S+) (.*)")
    
    return '[url=%s]%s[/url]' % href % text
end

local function tobbcode(style, buf)
    if styles[style] then
        return styles[style](buf)
    else
        print("[bbcode] [warn] unknown format: .%s{%s}" % style % buf)
    end
end

local function doit(chapter, options)
    print("[bbcode] rendering chapter %d to %s" % chapter.index % options.o)
    return output.expand(chapter.text, tobbcode)
end

return output.makefn(doit, "post.bbcode")

