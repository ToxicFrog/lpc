-- Generates BBcode output. Does not actually save to file; combine with
-- \out to save it somewhere.

function simple(tag)
    local open,close = "["..tag.."]","[/"..tag.."]"
    
    _ENV[tag] = function(text) return open..text..close end
end

--------------------------------------------------------------------------------
--      Basic Formatting
--------------------------------------------------------------------------------

-- bold
simple "b"

-- underline
simple "u"

-- strikethrough
simple "s"

-- superscript
simple "super"; ALIAS("^", super); ALIAS("sup", super)

-- subscript
simple "sub"; ALIAS("_", sub)

-- fixed width
simple "fixed"; ALIAS("tt", fixed)

-- hidden spoiler
simple "spoiler"

-- preformatted block
simple "pre"

-- code block
simple "code"

-- quote block
function quote(who, what)
    if not what then
        return "[quote]%s[/quote]" % who
    else
        return "[quote=%s]%s[/quote]" % { who, what }
    end
end

-- italic
-- we use MARK here so that \i{The good ship \i{Mary Celeste}} comes out
-- properly, ie, nested italics toggle it on and off
-- the POST rule will turn them into actual italic markers
function i(text)
    return MARK..text..MARK
end

function POST(text)
    local italic = false
    
    text = text:gsub(MARK, function()
        italic = not italic
        return italic and "[i]" or "[/i]"
    end)
    
    return text:trim()
end

--------------------------------------------------------------------------------
--      Emotes
--------------------------------------------------------------------------------

local emotes = {
    smile = ":)";
    frown = ":(";
    biggrin = ":D";
    wink = ";)";
}

function emote(name)
    return emotes[name] or (":%s:" % name)
end

--------------------------------------------------------------------------------
--      External References
--------------------------------------------------------------------------------

-- hyperlink
function url(url, text)
    return "[url=%s]%s[/url]" % { url, text or url }
end

-- inline images
simple "img"
simple "timg"
