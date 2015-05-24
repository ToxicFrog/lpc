-- Generates HTML output.

local defaults = {
  emote_path = "emote/";
  emote_type = "gif";
}
local options = setmetatable(..., {__index = defaults})

local function tag(t)
  local open,close = "<"..t..">","</"..t..">"

  lp.defmacro(t, 1, function(text)
    return open..text..close
  end)
end

--------------------------------------------------------------------------------
--      Basic Formatting
--------------------------------------------------------------------------------

-- Tags that are just open-content-close with no subtleties.
local simple_tags = { "b", "u", "s", "sup", "sub", "tt" }
for _,t in ipairs(simple_tags) do
  tag(t)
end

lp.defalias("^", "super")
lp.defalias("_", "sub")
lp.defalias("fixed", "tt")

-- hidden spoiler
lp.defmacro("spoiler", 1, function(text)
  return [[<span class="bbc-spoiler"]]
    .. [[ onmouseover="this.style.color='#FFFFFF';"]]
    .. [[ onmouseout="this.style.color=this.style.backgroundColor='#000000'">&nbsp;]]
    .. text
    .. [[&nbsp;</span>]]
end)

-- preformatted block
lp.defmacro('pre', 1, function(text)
  return '[quote [tt '..text..']]'
end)
lp.defalias('code', 'pre')

-- quote block
lp.defmacro('quote', 2, function(who, text)
  if who == '.' then
    return [[<div class="bbc-block"><blockquote>]]..text..[[</blockquote></div>]]
  else
    return [[<div class="bbc-block"><blockquote><h5>]]
      ..who..[[posted:</h5>]]..text..[[</blockquote></div>]]
  end
end)

-- Italics. This is hinky because we want nested italics to act as a toggle,
-- so that things like [i the starship [i Von Braun]] come out properly.
-- We handle this by registering two macros, i to turn italics on and !i to turn
-- them off; then we replace all i with !i in the body before returning.
lp.defmacro("i", 1, function(text)
  local function toggle(text)
    return text:gsub('^%[i ', '[!i ')
  end
  return '<i>'..text:gsub('%b[]', toggle)..'</i>'
end)
lp.defmacro("!i", 1, function(text)
  return '</i>'..text..'<i>'
end)

-- Emotes.
lp.defmacro('emote', 1, function(name)
  return "[image %s%s.%s]" % { options.emote_path, name, options.emote_type }
end)

lp.defmacro('url', 2, function(url, text)
  text = text or url
  return '<a href="'..url..'">'..text..'</a>'
end)
lp.defalias('link', 'url')

-- Images. TODO: click-to-resize on timg.
lp.defmacro('image', 1, function(url)
  return '<img src="'..url..'">'
end)
lp.defmacro('thumbnail', 1, function(url)
  return '<img width="256px" src="'..url..'">'
end)

lp.postprocess(function(text)
  return text:gsub('\n+', '<p>')
end)
