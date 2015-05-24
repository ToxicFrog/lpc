local cache = {}

local function loadcache(path, obj)
  local count = 0
  for line in io.lines(path) do
    count = count + 1
    local k,v = line:match("([^\t]+)\t(.*)")
    obj[k] = v
  end
  log.debug("cache: loaded %d entries from %s", count, path)
end

function cache.open(path)
  log.debug("cache: opening %s", path)
  local obj = {}

  -- read cache contents
  if io.exists(path) then
    loadcache(path, obj)
  end

  return setmetatable(obj, { __index = cache, path = path })
end

function cache:get(key)
  return self[key]
end

function cache:put(key, value)
  self[key] = value
end

function cache:save()
  -- write cache contents
  local fd = assert(io.open(getmetatable(self).path, "w"))

  for k,v in pairs(self) do
    fd:write("%s\t%s\n" % { k, v })
  end

  fd:close()
end

return cache
