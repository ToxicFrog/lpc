local http = require "socket.http"
local ltn12 = require "ltn12"

-- returns the contents of the given file
-- asserts() on error because if we can't open the file it should never get this far
local function fdata(filename)
    local fd = assert(io.open(filename, "rb"))
    local buf = fd:read "*a"
    fd:close()
    return buf
end

-- returns the size of the given file or nil,error
local function fsize(filename)
    local fd,err = io.open(filename, "rb")
    if not fd then return nil,err end
    
    local size = fd:seek("end")
    fd:close()
    return size
end

local function info(str)
    io.stdout:write("[wi] %s\n" % str)
end

-- generate the POST headers and body, given a filename to upload
local function mkpostcontent(filename)
    local boundary = "##ThIs_iS_ThE_BoUnDaRy##"
    
    local body = table.concat( {
        '--'..boundary,
        'Content-Disposition: form-data; name="mode"',
        '',
        'file',
        '--'..boundary,
        'Content-Disposition: form-data; name="client"',
        '',
        "ToxicFrog's Automated LP Assembly Engine",
        '--'..boundary,
        'Content-Disposition: form-data; name="file"; filename="%s"' % filename,
        'Content-Type: application/octet-stream',
        '',
        fdata(filename),
        '--'..boundary..'--',
        ''
    }, "\r\n")
    
    local head = {
        ["content-type"] = 'multipart/form-data; boundary=%s' % boundary;
        ["content-length"] = tostring(#body);
        ["accept"] = "text/xml";
    }

    return head,body
end

-- do the actual upload
local function wi_upload(filename)
    local head,body = mkpostcontent(filename)
    
    local response = {}
    local source = ltn12.source.string(body)
    local sent = 0
    
    local function progress()
        local data = source()
        sent = sent + #(data or "")
        local progress = sent/#body * 100;
        io.stdout:write("\r[wi] %s -> %d%" % filename % progress)
        io.stdout:flush()
        return data
    end
    
    local r,e = http.request {
        method = "POST";
        url = "http://waffleimages.com/upload";
        headers = head;
        source = progress;
        sink = ltn12.sink.table(response);
    }
    
    io.stdout:write("\r")
    
    if not r then
        return nil,tostring(e)
    end
    
    response = table.concat(response)
    local err = response:match('<err%s+type="(.*)"/>')
    if err then
        return nil,err
    end
    
    local url = response:match('<imageurl>(.*)</imageurl>')
    info( "%s -> %s" % filename % url )
    return url
end

local imagelist

local function load_imagelist()
    local f,e = loadfile(".wi-list")
    if not f then
        info("[warn] can't open waffleimages upload list (.wi-list)")
        info("[warn] reason: %s" % e)
        info("[warn] uploading all images instead of skipping already-uploaded ones")
        imagelist = {}
    else
        imagelist = f()
    end
end

local function save_imagelist()
    local fout,err = io.open(".wi-list", "wb")
    
    if not fout then
        info("[err] can't update waffleimages upload list (.wi-list)")
        info("[err] reason: %s" % err)
        return
    end
    
    fout:write("return {\n")
    for k,v in pairs(imagelist) do
        fout:write("    [%q] = { size=%d, url=%q };\n" % k % v.size % v.url)
    end
    fout:write("}\n")
    fout:close()
end

local function getwipath(path)
    local img = imagelist[path]
    local size,err = fsize(path)
    
    if not img then
        img = { size=-1, url="" }
    end
    
    if not size then
        info("[err] %s -- %s" % path % err)
        return "<error>"
    end
    
    if img.size == size then
        info("%s -> %s" % path % img.url)
        return img.url
    end
    
    img.size = size
    img.url,err = wi_upload(path)
    
    if not img.url then
        info("[err] %s -- %s" % path % err)
        imagelist[path] = nil
        return "<error>"
    end
    
    imagelist[path] = img
    save_imagelist()
    return img.url
end

return function(path)
    if not imagelist then
        load_imagelist()
    end
    
    return getwipath(path)
end

