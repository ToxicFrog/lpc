-- This package is automatically loaded for each file parsed.
-- It defines some basic commands: use, def, include, and --

-- [-- ...]
-- discards its contents
local function comment(text)
  return ""
end

-- [include file]
-- expands to the contents of file
local function include(file)
  local dir = FILE:gsub('[^/]+$', '')
  return io.readfile('./'..dir..'/'..file)
end

-- [def name argc body]
-- define a new macro; \n in the body is replaced with the value of the nth
-- arg when it expands, e.g. [def bold 1 \textbf{\1}]
function def(name, argc, body)
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

  defmacro(name, argc, f)
  return ""
end

defmacro('use', nil, use)
defmacro('--', 1, comment)
defmacro('include', 1, include)
defmacro('def', 3, def)
defmacro('defalias', 2, function(to, from)
  defalias(to, from)
  return ''
end)

-- return {
--   macro('use', '*', use)
--   macro('--', comment)
--   macro('include', include)
--   macro('def', 2, def)
-- }
