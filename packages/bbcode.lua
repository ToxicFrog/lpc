-- Generates bbcode output.

local function tag(t, macro)
  macro = macro or t
  local open,close = "[\\"..t.."]","[\\/"..t.."]"
  lp.defmacro(macro, 1, function(text)
    return open..text..close
  end)
end

-- Tags that are just open-content-close with no subtleties.
local simple_tags = {
  "b", "u", "s", "super", "sub", "fixed", "spoiler",
  "pre", "code",
}

for _,t in ipairs(simple_tags) do
  tag(t)
end

tag('img', 'image')
tag('timg', 'thumbnail')

-- Convenient aliases for the above.
lp.defalias("sup", "super")

lp.defalias("^", "super")
lp.defalias("_", "sub")

lp.defalias("tt", "fixed")

-- Quote block with optional name. [quote . text] omits the name.
lp.defmacro("quote", 2, function(name, text)
  if name ~= "." then
    return "[\\quote=\"%s\"]%s[\\/quote]" % { name, text }
  else
    return "[\\quote]%s[\\/quote]" % text
  end
end)

-- Hyperlink. [url foo text] links text to foo, [url foo] is eqv to [url foo foo].
lp.defmacro("url", 2, function(url, text)
  text = text or url
  return "[\\url=%s]%s[\\/url]" % { url, text }
end)
lp.defalias('link', 'url')

-- Italics. This is hinky because we want nested italics to act as a toggle,
-- so that things like [i the starship [i Von Braun]] come out properly.
-- We handle this by registering two macros, i to turn italics on and !i to turn
-- them off; then we replace all i with !i in the body before returning.
lp.defmacro("i", 1, function(text)
  local function toggle(text)
    return text:gsub('^%[i ', '[!i ')
  end
  return '[\\i]'..text:gsub('%b[]', toggle)..'[\\/i]'
end)
lp.defmacro("!i", 1, function(text)
  return '[\\/i]'..text..'[\\i]'
end)

-- Emotes.
local emotes = {
  smile   = ":)";
  frown   = ":(";
  biggrin = ":D";
  wink    = ";)";
}

lp.defmacro("emote", 1, function(name)
  return emotes[name] or (":%s:" % name)
end)

