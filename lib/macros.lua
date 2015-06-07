-- Functions for the macro engine.
-- lp.expand() is used to actually apply macros to text
-- lp.defmacro and lp.defalias create and alias macros respectively

local macros = {}

-- Given document text and a [name => function] mapping of mac Functions for the macro engine.
-- lp.expand() i Functions for the macro engine.
-- lp.expand() iros, expand all
-- of the macros in the text, recursively.
function lp.expand(text)
  local expand_one,expand_all

  -- Split a string into <argc> args. Normally args are whitespace-separated,
  -- but any [...] is counted as a single arg.
  local function split_args(argc, argv)
    local args,arg = {},nil
    argv = argv:trim()
    log.debug("split_args: %f '%s'", argc, argv)
    -- We check args+1 here because we want to collect the whole tail into the
    -- the last arg.
    while #argv > 0 and #args+1 < argc do
      log.debug("      init: %f '%s'", argc, argv)
      if argv:match("^%b[]") then
        arg,argv = argv:match("^(%b[])(.*)")
        if arg:sub(1,2) == "[." then
          -- [.foo bar] makes 'foo bar' all one argument in the parser but has
          -- no other effect; outside the parser it's equivalent to [\...]
          arg = arg:sub(3,-2)
        end
        log.debug("    insert: %s", arg)
        table.insert(args, arg)
      elseif argv:match("^%S+") then
        arg,argv = argv:match("^(%S+)(.*)")
        log.debug("    insert: %s", arg)
        table.insert(args, arg)
      else
        error("Inconsistency in argument parser. This should never happen.\n"
          .." argc="..argc
          .." argv="..argv
          .." args="..table.concat(args, ","))
      end
      argv = argv:trim()
    end
    -- collect remaining text as the tail arg; if you do [url foo bar baz]
    -- and [url] takes 2 arguments, the arguments should be 'foo' and 'bar baz'
    if #argv > 0 then
      table.insert(args, argv)
    end
    return args
  end

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

    if text:sub(1,2) == '[.' then
      -- Things of the form [.foo ...] are quote/groups; the [. and ] are dropped
      -- and the contents emitted as normal.
      return text:sub(3,-2)..newlines
    end

    local name,argv = text:sub(2, -2):split(nil, 1)
    local macro = macros[name]

    if not macro then
      log.warning("Unknown macro: %s", text)
      return
    end

    log.debug("Processing macro (%s) with args (%s)", name, argv)

    -- 'argv' at this point is still a single string, so we split it based
    -- on the macro's argc value. If nil, they get each word as an individual
    -- argument.
    argv = split_args(macro.argc or math.huge, argv or '')
    if #argv < macro.argc and macro.argc ~= math.huge then
      log.error('Too few arguments to (%s): %.0f < %.0f', name, #argv, macro.argc)
      return ''
    end
    log.debug("    After parsing, %d args are: %s", #argv, table.concat(argv, ","))
    result = macro.fn(unpack(argv))

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

local function macro(name, argc, fn)
  return {
    name = name;
    argc = (argc or math.huge);
    fn = fn;
  }
end

function lp.defmacro(...)
  local m = macro(...)
  if macros[m.name] then
    log.warning("Multiple definitions of macro %s", m.name)
  end
  log.debug("Registering macro %s (%s args) with %s", m.name, m.argc, m.fn)
  macros[m.name] = m
end

function lp.defalias(to, from)
  macros[to] = macros[from]
end
