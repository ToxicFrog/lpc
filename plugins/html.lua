-- Generates HTML output. Does not actually save to file; combine with
-- \out to save it somewhere.

-- {emote_path=smilies/} OPTIONAL. prefix emoticons with this path. Default is 'smilies/'
-- {emote_type=gif} OPTIONAL. suffix emoticons with this extension. Default is 'gif'.

emote_path = emote_path or "smilies/"
emote_type = emoty_type or "gif"

function simple(tag)
    local open,close = "<"..tag..">","</"..tag..">"
    
    _ENV[tag] = function(text) return "<%s>%s</%s>" % { tag, text, tag } end
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
simple "sup"; ALIAS("^", sup); ALIAS("super", sup)

-- subscript
simple "sub"; ALIAS("_", sub)

-- fixed width
simple "tt"; ALIAS("fixed", tt)

-- hidden spoiler
function spoiler(text)
    return [[<span class="bbc-spoiler" onmouseover="this.style.color='#FFFFFF';" onmouseout="this.style.color=this.style.backgroundColor='#000000'">&nbsp;%s&nbsp;</span>]]
    % text
end

-- preformatted block
function pre(text)
    return quote(pre(text))
end

-- code block
function code(text)
    return quote(pre(text))
end

-- quote block
function quote(who, what)
    if not what then
        return [[<div class="bbc-block"><blockquote>%s</blockquote></div>]] % who
    else
        return [[<div class="bbc-block"><blockquote><h5>%s posted:</h5>%s</blockquote></div>]] % { who, what }
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
        return italic and "<i>" or "</i>"
    end)
    
    return text:trim()
end

--------------------------------------------------------------------------------
--      Emotes
--------------------------------------------------------------------------------

function emote(name)
    return img("%s%s.%s" % { emote_path, name, emote_type })
end

--------------------------------------------------------------------------------
--      External References
--------------------------------------------------------------------------------

-- hyperlink
function url(url, text)
    return '<a href="%s">%s</a>' % { url, text or url }
end

-- inline images
function img(url)
    return '<img src="%s">' % url
end

function timg(url)
    return '<img src="%s" width="170px">' % url
end
