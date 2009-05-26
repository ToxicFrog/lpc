local styles = {}

function styles.b(buf)
    return "[b]%s[/b]" % buf
end

function styles.i(buf)
    return "[i]%s[/i]" % buf
end

function styles.s(buf)
    return "[s]%s[/s]" % buf
end

function styles.img(buf)
    return '[img]http://%s/%s/%s.png[/img]' % lp.imghost % lp.imgpath % buf
end

function styles.url(buf)
    local href,text = buf:match("(%S+) (.*)")
    
    return "[url=%s]%s[/url]" % href % text
end

function styles.super(buf)
    return "[super]%s[/super]" % buf
end

local function tobbcode(style, buf)
    if styles[style] then
        return styles[style](buf:sub(2,-2))
    else
        return error("Invalid format/style key: "..style)
    end
end

return styles

local function expand(str)
    local str,n = str:gsub("%.(%w+)(%b{})", tobbcode)
    if n > 0 then
        return expand(str)
    else
        return str
    end
end

function lp.write(fd, str)
    fd:write( expand(str) )
end

lp.filename = "post.txt"

