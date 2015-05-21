#!/usr/bin/env luajit

package.path = package.path..";lib/?.lua;lib/?/init.lua"

require "util.flags"
require "util.logging"
require "util.string"
require "util.io"

lp = {}

-- Given document text and a [name => function] mapping of macros, expand all
-- of the macros in the text, recursively.
function lp.expand(text, macros)
  local expand_one,expand_all

  -- Find all macros, which are basically []-delimited sexprs, and expand
  -- each one.
  function expand_all(text)
    return (text:gsub('(%b[])(\n*)', expand_one))
  end

  -- Given a macro (still with the [] on it!), expand it.
  function expand_one(text, newlines)
    if text:sub(1,2) == '[\\' then
      -- Things of the form [\foo ...] are escapes; this is not a macro,
      -- just drop the \ and emit the rest as normal
      return text:gsub('^%[\\', '[')..newlines
    end

    local name,argv = text:sub(2, -2):split(nil, 1)
    local macro = macros[name]

    if not macro then
      log.warning("Unknown macro: %s", text)
      return
    end

    log.debug("Processing macro (%s) with args (%s)", name, argv)

    -- 'args' at this point is still a single string, so we split it based
    -- on the macro's argc value. If nil, they get each word as an individual
    -- argument.
    result = macro.fn(argv:split(nil, macro.argc))

    if type(result) ~= 'string' then
      log.error('Macro did not return a string: %s', text)
      result = ''
    end

    -- Funny heuristic here. If the macro ends a line, and evaluates to the
    -- empty string, we drop the entire line instead, and all blank lines
    -- following. This means that things like [use] directives don't turn into
    -- blank lines which in turn get turned into extra empty paragraphs.
    if #result == 0 and #newlines > 0 then
      return ''
    else
      return expand_all(result..newlines)
    end
  end

  return expand_all(text)
end

local macros = {}

function macro(name, argc, fn)
  log.debug("Registering macro %s (%s args) with %s", name, argc, fn)
  return {
    name = name;
    argc = (argc and argc-1);
    fn = fn;
  }
end

function defmacro(...)
  local m = macro(...)
  if macros[m.name] then
    log.warning("Multiple definitions of macro %s", m.name)
  end
  macros[m.name] = m
end

function defalias(to, from)
  macros[to] = macros[from]
end

require "lib.core"
flags.parse(...)

-- We load each file with the "init" filter and nothing else. This defines some
-- basic macros, including \include and \use, which the file will use (if
-- needed) to load additional filters. \use adds the filters to a list which is
-- run by POST once init has finished all other processing.
for _,file in ipairs(flags.parsed) do
  FILE = file
  print(lp.expand(io.readfile(file), macros))
end
