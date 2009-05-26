local http = require "socket.http"
local ltn12 = require "ltn12"

function str__mod(lhs, rhs)
    if type(rhs) == "table" then
        return lhs:format(unpack(rhs))
    else
        return lhs:gsub('%%', '%%%%'):gsub('%%%%', '%%', 1):format(rhs)
    end
end

getmetatable("").__mod = str__mod

local function fdata(filename)
    local fd = assert(io.open(filename, "rb"))
    local buf = fd:read "*a"
    fd:close()
    return buf
end

function wi_upload(filename)
    local boundary = "##ThIs_iS_ThE_BoUnDaRy##"
    
    local body = {
        '--'..boundary,
        'Content-Disposition: form-data; name="mode"' % name,
        '',
        'file',
        '--'..boundary,
        'Content-Disposition: form-data; name="client"' % name,
        '',
        "ToxicFrog's Automated LP Assembly Engine",
        '--'..boundary,
        'Content-Disposition: form-data; name="file"; filename="%s"' % filename,
        'Content-Type: application/octet-stream',
        '',
        fdata(filename),
        '--'..boundary..'--',
        ''
    }
    
    body = table.concat(body, "\r\n")
    
    local head = {
        ["content-type"] = 'multipart/form-data; boundary=%s' % boundary;
        ["content-length"] = tostring(#body);
        ["accept"] = "text/xml";
    }
    
    local response = {}
    local source = ltn12.source.string(body)
    local sent = 0
    
    local function progress()
        local data = source()
        sent = sent + #(data or "")
        local progress = sent/#body * 100;
        io.stdout:write("\rUploading %s: %d%" % filename % progress)
        return data
    end
    
    local r,e = http.request {
        method = "POST";
        url = "http://waffleimages.com/upload";
        headers = head;
        source = progress;
        sink = ltn12.sink.table(response);
    }
    
    print()

    if not r then
        return nil,tostring(e)
    end
    
    response = table.concat(response)
    local err = response:match('<err%s+type="(.*)"/>')
    if err then
        return nil,err
    end
    
    local url = response:match('<imageurl>(.*)</imageurl>')
    return url
end

