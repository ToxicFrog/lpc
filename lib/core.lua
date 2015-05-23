-- This package is automatically loaded for each file parsed.
-- It defines some basic commands: use, def, include, and --

local library_paths = { "./plugins" }

-- Load a package.
-- This looks in every directory in library_paths, in order (so stuff specified
-- later takes precedence). For each package, it first looks for exactly the
-- file specified; failing that it looks for one ending in .lpc, then one ending
-- in .lua. It stops after the first one it finds.
local function use(package, ...)
  local options = {}
  for _,opt in ipairs {...} do
    local k,v = opt:match("([^=]+)=(.*)")
    if k then
      options[k] = v
    else
      options[opt] = true
    end
  end

  for _,dir in ipairs(library_paths) do
    local path = dir.."/"..package
    if io.exists(path) then
    elseif io.exists(path..".lpc") then
      -- load lpc file
      log.error("Not implemented yet: load LPC library %s.lpc", path)
      return ''
    elseif io.exists(path..".lua") then
      -- load lua file
      assert(loadfile(path..".lua"))()
      log.error("Not implemented yet: load lua library %s.lua", path)
      return ''
    end
  end
  log.error("Unable to load library: %s", package)
end

flags.register("L", "library-path") {
  help = "Search for lpc libraries in this directory.";
  type = flags.string;
  set = function(k,v) table.insert(library_paths, v, 1) end;
}

flags.register("l", "library") {
  help = "Load this library before any file processing is performed.";
  type = flags.string;
  set = function(k,v) use(v) end;
}

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
