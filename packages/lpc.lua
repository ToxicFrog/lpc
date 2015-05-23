-- Core package for lpc.
-- Provides def, defalias, --, include, and use.
-- This package is automatically loaded before the file is processed.

-- Package loading.
lp.defmacro('use', nil, lp.use)

-- Comments.
lp.defmacro('--', 1, function()
  return ''
end)

-- [include file]
-- Expands to the contents of the file. File is loaded relative to the file
-- being processed.
lp.defmacro('include', 1, function(file)
  local dir = FILE:gsub('[^/]+$', '')
  return io.readfile('./'..dir..'/'..file)
end)

-- [def name argc body]
-- Define a new macro; \n in the body is replaced with the value of the nth
-- arg when it expands, e.g. [def bold 1 \textbf{\1}].
lp.defmacro('def', 3, function(name, argc, body)
  if argc == '*' then argc = nil
  else argc = tonumber(argc)
  end

  local function f(...)
    local argv = {...}
    return (body:gsub("([^\\])\\(%d+)",
      function(prefix, i)
        return prefix..argv[tonumber(i)]
      end)
      :gsub('\\\\', '\\'))
  end

  lp.defmacro(name, argc, f)
  return ""
end)

-- [defalias to from]
-- Makes <to> an alias for <from>.
-- Binds to the current value of <from>; if it changes the later the alias is
-- unaffected.
lp.defmacro('defalias', 2, function(to, from)
  lp.defalias(to, from)
  return ''
end)
