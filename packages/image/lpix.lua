-- plugin for automatically uploading images to lpix.org
-- options:
--  user    lpix login name
--  pass    lpix password
--  gallery lpix gallery to upload to
--  notimg  if true, use lpix thumbnails rather than [timg]
--  noerror if true, continue on error rather than aborting compilation

local lpix = require "lpix"

local options = lp.options(...) {
  user = nil;
  pass = nil;
  gallery = nil;
  notimg = false;
  noerror = false;
}

assert(options.user, "No username specified for lpix.")
assert(options.pass, "No password specified for lpix.")

local function key(path)
  if not io.exists(path) then return end
  return "lpix:%s:%d" % { path, io.size(path) }
end

local function upload(path)
  if not io.exists(path) then
    log.error("lpix: no such file: %s", path)
    return
  end

  log.info('lpix: uploading %s', path)

  local result,err = lpix.upload(options.user, options.pass, path, options.gallery)

  if result then
    lp.cache:put(key(path), result.imageurl)
    lp.cache:put(key(path)..":thumb", result.thumburl)
    lp.cache:save()
    return result.imageurl,result.thumburl
  elseif options.noerror then
    log.error("lpix: error uploading '%s' (%s)", path, err)
  else
    error(err)
  end
end

lp.defmacro('img', 1, function(path)
  if path:match("^http://") then return end

  if not lp.cache:get(key(path)) and not upload(path) then return end

  return '[image %s]' % lp.cache:get(key(path))
end)

lp.defmacro('timg', 1, function(path)
  if path:match("^http://") then return end

  if not lp.cache:get(key(path)..":thumb") and not upload(path) then return end

  if options.notimg then
    return '[image %s]' % lp.cache:get(key(path)..":thumb")
  else
    return '[thumbnail %s]' % cache:get(path)
  end
end)
