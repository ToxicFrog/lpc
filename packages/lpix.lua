-- plugin for automatically uploading images to lpix.org
-- options:
--  {user=username} REQUIRED. Login name for lpix.
--  {pass=password} REQUIRED. Login password for lpix.
--  {gallery=name} OPTIONAL. Gallery to put images in.
--  {notimg} OPTIONAL. Use lpix thumbnails rather than [timg] for \timg.
--  {noerror} OPTIONAL. Treat errors as warnings and keep going.

local lpix = require "lpix"
local IMARK,TMARK = MARK.."I", MARK.."T"
local cache

local function upload(path)
    LOG("Uploading %s", path)
    
    local result,err = lpix.upload(user, pass, path, gallery)

    if result then
        cache:put(path, result.imageurl)
        cache:put(path.."/thumb", result.thumburl)
    elseif noerror then
        LOG("error uploading '%s' (%s)", path, err)
    else
        error(err)
    end
end

function PRE(text)
    assert(user and pass, "lpix: username and password required - try \use{lpix}{user=me}{pass=secret}")
    
    cache = (require "cache" . open("lpix"))
end

function img(path)
    if path:match("^http://") then return end
    
    if not cache:get(path) then
        upload(path)
    end
    
    return [[%s{%s}]] % { IMARK, cache:get(path) or path }
end

function timg(path)
    if path:match("^http://") then return end
    
    if not cache:get(path) then
        upload(path)
    end
    
    if notimg then
        return [[%s{%s}]] % { IMARK, cache:get(path.."/thumb") or path }
    else
        return [[%s{%s}]] % { TMARK, cache:get(path) or path }
    end
end

function POST(text)
    cache:save()
    return text:gsub(IMARK, [[\img]]):gsub(TMARK, [[\timg]])
end
