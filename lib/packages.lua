-- functions and flags for loading packages

flags.register('package-path', 'L') {
  help = 'Search for lpc libraries in this directory.';
  type = flags.string;
  repeated = true;
  default = { BASEDIR..'/packages' };
}

flags.register('package', 'l') {
  help = 'Load this library before any file processing is performed.';
  type = flags.string;
  repeated = true;
  default = { 'lpc' };
}

-- Load a package.
-- This looks in every directory in library_paths, in order (so stuff specified
-- later takes precedence). For each package, it first looks for exactly the
-- file specified; failing that it looks for one ending in .lpc, then one ending
-- in .lua. It stops after the first one it finds.
function lp.use(package, ...)
  log.info('Loading package %s', package)
  local options = {}
  for _,opt in ipairs {...} do
    local k,v = opt:match('([^=]+)=(.*)')
    if k then
      options[k] = v
    else
      options[opt] = true
    end
  end

  for _,dir in ipairs(flags.parsed.package_path) do
    local path = dir..'/'..package
    if io.exists(path) then
    elseif io.exists(path..'.lpc') then
      -- load macro file
      local message = lp.expand(assert(io.readfile(path..'.lpc')))
      if #message > 0 then
        log.info('From loading package '%s':\n%s', package, message)
      end
      return ''
    elseif io.exists(path..'.lua') then
      -- load lua file
      assert(loadfile(path..'.lua'))(options)
      return ''
    end
  end
  log.error('Unable to load package: %s', package)
  return ''
end
