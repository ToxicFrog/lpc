local styles = {}

local function basic_style(tag)
    local format = "<"..tag..">%s</"..tag..">"
    styles[tag] = function(buf)
        return format % buf
    end
end

-- basic HTML tags
for _,tag in ipairs { "b", "s", "u", "super", "sub", "pre", "tt" } do
    basic_style(tag)
end

-- special handling for italics - if they're on, turns them off, and if off, on
function styles.i(buf)
    return "<i>%s</i>" % buf:gsub("%.i(%b{})", ".ii%1")
end

function styles.ii(buf)
    return "</i>%s<i>" % buf:gsub("%.ii(%b{})", ".i%1")
end

function styles.img(buf)
    return '<img src="%s" />' % buf
end

function styles.url(buf)
    local href,text = buf:match("(%S+) (.*)")
    
    return '<a href="%s">%s</a>' % href % text
end

function styles.super(buf)
    return "<super>%s</super>" % buf
end

local function tohtml(style, buf)
    if styles[style] then
        return styles[style](buf)
    else
        print("[html] [warn] unknown format: .%s{%s}" % style % buf)
    end
end

local function doit(chapter, options)
    print("[html] rendering chapter %d to %s" % chapter.index % options.o)
    return (output.expand(chapter.text, tohtml):gsub("\n", "<br>\n"));
end

return output.makefn(doit, "post.html")
