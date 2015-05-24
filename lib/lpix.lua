require "util.io"

local lpix = {}

local errors = {
    err2 = "Invalid username/password";
    err3 = "Not an image";
    err4 = "File too large";
}

function lpix.upload(user, pass, filename, gallery)
    gallery = gallery or "Default"

    assert(user and pass and filename, "lpix.upload: too few arguments")

    local post = require("http-post").new()

    post:field("username", user)
    post:field("password", pass)
    post:field("gallery", gallery)
    post:field("output", "xml")

    if filename:match("^http://") then
        post:field("url", filename)
    else
        local size,err = io.size(filename)
        if not size then
            return nil,"lpix: cannot open file: %s" % err
        elseif size > 2*1024*1024 then
            return nil,"lpix: file '%s' is too large (%d bytes)" % { filename, size }
        end

        post:file("file", filename)
    end

    local resp,err = post:post("http://lpix.org/api")
    if not resp then return nil,err end

    local err = resp:match('<err type="([^"]+)')
    if err then
        return nil,errors[err] or ("(unknown error %s)" % err)
    end

    local results = {}

    for key,value in resp:gmatch("<(%w+)>([^<]+)</%w+>") do
        results[key] = value
    end

    return results
end

return lpix
