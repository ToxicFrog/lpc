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
        return styles[style](buf:sub(2,-2))
    else
        return error("Invalid format/style key: "..style)
    end
end

local function expand(chapter)
    require "util"; table.print(chapter)
    local str,n = chapter.text:gsub("%.(%w+)(%b{})", tohtml)
    if n > 0 then
        return expand(str)
    else
        return (str:gsub("\n", "<br>\n"))
    end
end

return output.makefn(expand, "post.html")
    